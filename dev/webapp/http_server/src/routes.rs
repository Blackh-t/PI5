use crate::handler::git_pull_service::*;
use crate::handler::system_usage::Metrics;
use actix_files as fs;

use actix_web::{
    web::{self, head, post, scope},
    HttpResponse,
};

/// Executes git pull service on newly git commit.
/// GitHub send a post request on git commit in PI5 repo, testing branch.
pub fn webhook_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        scope("/webhook")
            .route("", post().to(git_pull))
            .route("", head().to(HttpResponse::MethodNotAllowed)),
    );
}

/// Serve static files for monitoring server and services status.
pub fn monitor_routes(cfg: &mut web::ServiceConfig) {
    cfg.service(
        scope("/monitor").service(
            fs::Files::new("", "../monitor_app")
                .index_file("index.html")
                .show_files_listing(),
        ),
    );
}

// Add this to configure your routes
pub fn system_routing(cfg: &mut web::ServiceConfig) {
    // Route: GET /btop
    cfg.service(
        web::scope("/system_routing")
            .route("/cpu", web::get().to(Metrics::get_cpu_usage))
            .route("/mem", web::get().to(Metrics::get_mem_usage))
            .route("/disk", web::get().to(Metrics::get_disk_usage)),
    );
}
