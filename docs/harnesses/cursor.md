# Cursor

Add this repository as a team marketplace from **Settings → Plugins → Team Marketplaces → Add Marketplace → Import from Repo**, pointing it at this repo.

Cursor indexes the plugins listed in [`.cursor-plugin/marketplace.json`](../../.cursor-plugin/marketplace.json) on import, then installs each plugin's `.cursor-plugin/plugin.json`, which points at that plugin's `skills/` directory.
