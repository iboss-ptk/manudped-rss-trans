use std::error::Error;

use lambda_runtime::{error::HandlerError, lambda, Context};
use log;
use serde_derive::{Deserialize, Serialize};
use simple_logger;
use std::collections::HashMap;
use rss::Channel;

#[derive(Deserialize, Debug)]
struct Request {
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct ProxyResponse {
    status_code: u16,
    headers: HashMap<String, String>,
    body: String,
    is_base_64_encoded: bool,
}

fn main() -> Result<(), Box<dyn Error>> {
    simple_logger::init_with_level(log::Level::Debug).unwrap();
    lambda!(handler);

    Ok(())
}

const CHAN_URL: &str = "http://feeds.soundcloud.com/users/soundcloud:users:573621174/sounds.rss";
const LANG: &str = "th";

fn handler(_e: Request, _c: Context) -> Result<ProxyResponse, HandlerError> {
    let mut channel = Channel::from_url(CHAN_URL).unwrap();
    channel.set_language(LANG.to_string());

    let body = format!("<?xml version='1.0' encoding='UTF-8'?>\n{}", channel.to_string());

    let mut headers = HashMap::new();
    headers.insert(
        "Content-Type".to_string(),
        "application/rss+xml;charset=utf-8".to_string(),
    );

    Ok(ProxyResponse {
        status_code: 200,
        headers,
        body,
        is_base_64_encoded: false,
    })
}
