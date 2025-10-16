use axum::{
    http::HeaderMap,
    response::IntoResponse,
    routing::{get, post},
    Router,
};
use hex;
use hmac::{Hmac, Mac};
use sha2::Sha256;
use std::env;
use std::process::Command;
use std::process::Stdio;

#[tokio::main]
async fn main() {
    let tailscale_ip = env::var("TS_IP").unwrap_or("0.0.0.0".to_string());
    let port = env::var("TS_PORT").unwrap_or("3000".to_string());
    println!("Listening on {}:{}", tailscale_ip, port);

    // build our application with a single route
    let app = Router::new().route("/webhook", post(git_pull)).route(
        "/",
        get(|| async {
            // Get systemd status.
            let output = Command::new("/usr/local/bin/check_services.sh")
                .stdout(Stdio::piped())
                .stderr(Stdio::piped())
                .output()
                .expect("failed to execute script");

            // Create the response body.
            let body = String::from_utf8_lossy(&output.stdout).to_string();
            body.into_response()
        }),
    );

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind(format!("{}:{}", tailscale_ip, port))
        .await
        .unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn git_pull(headers: HeaderMap, body: String) {
    // Get Signature.
    let sign = headers
        .get("X-Hub-Signature-256")
        .and_then(|v| v.to_str().ok())
        .unwrap_or("");

    // Verify the signature.
    let secret = env::var("SECRET_TOKEN").unwrap_or("".to_string());
    if sign != generate_sign(&secret, body.as_bytes()) {
        println!("[ Invalid ] Signature!");
        return;
    }

    // Run the script.
    println!("[ OK ] -- webhook -> running git_pull.sh");
    let git_pull_script = env::var("SCRIPT_PATH").unwrap();
    Command::new(git_pull_script)
        .status()
        .expect("[ Invalid ] -- PATH");
}

fn generate_sign(secret: &str, payload: &[u8]) -> String {
    type HmacSha256 = Hmac<Sha256>;

    // Signature = secret + payload.
    let mut hmac = HmacSha256::new_from_slice(secret.as_bytes()).unwrap();
    hmac.update(payload);

    // Return expected sign in hex.
    let res = hmac.finalize().into_bytes();
    format!("sha256={}", hex::encode(res))
}

// Tests
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_sign() {
        let secret = "It's a Secret to Everybody";
        let payload = "Hello, World!".as_bytes();

        let signature = generate_sign(secret, payload);
        let expected = "sha256=757107ea0eb2509fc211221cce984b8a37570b6d7586c22c46f4379c8b043e17";

        assert_eq!(signature, expected);
    }
}
