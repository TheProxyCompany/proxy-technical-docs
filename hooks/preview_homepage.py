"""Keep the website review's docs preview linked to its matching website."""

import os


def on_config(config):
    if os.environ.get("CF_PAGES") == "1" and os.environ.get("CF_PAGES_BRANCH") == "stack/website":
        config.extra["homepage"] = (
            "https://codex-website-reimagined.the-proxy-company-website.pages.dev/"
        )
    return config
