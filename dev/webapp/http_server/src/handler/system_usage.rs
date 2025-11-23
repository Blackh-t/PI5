use awc;
use serde_json;

use actix_web::HttpResponse;
use serde_json::Value;

pub struct Metrics;
impl Metrics {
    pub async fn get_cpu_usage() -> HttpResponse {
        Self::fetch_metric("cpu/total").await
    }

    pub async fn get_mem_usage() -> HttpResponse {
        Self::fetch_metric("mem/percent").await
    }

    pub async fn get_disk_usage() -> HttpResponse {
        Self::fetch_metric("fs/percent").await
    }

    async fn fetch_metric(resource: &str) -> HttpResponse {
        // Construct the specific URL dynamically
        let url = format!("http://127.0.0.1:7778/api/4/{}", resource);
        let client = awc::Client::default();

        // Perform the request
        let mut response = client.get(&url).send().await.unwrap();
        let payload = response.body().limit(20_000_000).await.unwrap();

        // Generic deserialization
        let value: Value = serde_json::from_slice(&payload).expect("x");

        let usage_percent = 'search: {
            if let Some(obj) = value.as_object() {
                for (_, value) in obj {
                    // Case 1: Signle value
                    if let Some(val) = value.as_f64() {
                        break 'search val;
                    }
                    // Case 2: Array.
                    if let Some(arr) = value.as_array() {
                        let val = arr.first().and_then(|v| v.as_f64()).unwrap();
                        break 'search val;
                    }
                }
            }
            0.0
        };
        HttpResponse::Ok().body(format!("{usage_percent}"))
    }
}
