use axum::{routing::post, Router};
use std::process::Command;

#[tokio::main]
async fn main() {
    // build our application with a single route
    let app = Router::new().route("/webhook", post(git_pull));
    println!("Listening on 0.0.0.0:3000");

    // run our app with hyper, listening globally on port 3000
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn git_pull() {
    println!("[Received] -- webhook -> running git_pull.sh");

    let _ = Command::new("/home/yoshi/git/PI5/bin/git_pull.sh")
        .status()
        .expect("[Invalid] -- PATH");
}
