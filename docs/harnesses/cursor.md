# Cursor

Add this repository as a team marketplace from **Settings → Plugins → Team Marketplaces → Add Marketplace → Import from Repo**, pointing it at this repo.

Cursor indexes the plugins listed in [`.cursor-plugin/marketplace.json`](../../.cursor-plugin/marketplace.json) on import, then installs each plugin's `.cursor-plugin/plugin.json`, which points at that plugin's `skills/` directory.

For a plugin that ships `agents/`, the skill runs every stage inline and reads each stage's definition from `agents/` (`../../agents/` from the skill directory) when the install places that directory beside `skills/` — not confirmed for Cursor's marketplace install. If it is missing, copy `plugins/<plugin-name>/agents` next to the installed plugin's `skills/` directory by hand.
