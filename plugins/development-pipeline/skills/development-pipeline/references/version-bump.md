# Project version bump

Read when the user has asked for a version bump in their request (`SKILL.md` 2a). Part of the orchestrator rules in `SKILL.md`; "the sizing question" is its one opt-in `AskUserQuestion`.

- Use Semantic Versioning `vX.Y.Z` — X major (breaking change), Y minor (new feature, backward-compatible), Z patch (fix or improvement); a higher part resets the lower ones to 0. Find where the project records its version (e.g. `VERSION`, `package.json`, `*.csproj`, a version constant, the latest `v*` git tag); confirm the target with one line of reasoning (`v1.4.2 → v1.5.0, new endpoint`) in the sizing question, or ask where to record it if none exists. Pass the confirmed version and file to implementation-planner, which assigns that file to exactly one package (for a trivial fix, apply it yourself). Fix rounds inside the same delivery never bump again. Never create a git tag — propose `git tag vX.Y.Z` at close-out.
