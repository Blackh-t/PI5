use axum::{routing::post, Router};
use std::env;
use std::process::Command;

#[tokio::main]
async fn main() {
    // build our application with a single route
    let app = Router::new().route("/webhook", post(git_pull));

    let tailscale_ip = env::var("TS_IP").unwrap_or("0.0.0.0".to_string());
    let port = env::var("TS_PORT").unwrap_or("3000".to_string());
    println!("Listening on {tailscale_ip}:{port}");

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("{tailscale_ip}:{port}")
        .await
        .unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn git_pull() {
    println!("[Received] -- webhook -> running git_pull.sh");

    let git_pull_script = env::var("SCRIPT_PATH").unwrap();
    let _ = Command::new(git_pull_script)
        .status()
        .expect("[Invalid] -- PATH");
}
