# Code conventions

One file per language or framework. Each is self-contained: a brief points at the file(s) matching the stack it touches, and at nothing else. Duplication between files is deliberate — an agent reads one file, not the set.

| File | Stack |
|---|---|
| `javascript-typescript.md` | JavaScript, TypeScript |
| `cocos-creator.md` | Cocos Creator engine/editor artifacts — pair with `javascript-typescript.md` for script code |
| `csharp.md` | C# |
| `go.md` | Go |

Every file follows the same shape: scope and upstream reference, precedence, naming (table, then the prefix/acronym expansions), language guidelines, layout and comments, and a closing list of the house rules that depart from upstream.

Adding a stack: copy that shape, name the upstream style guide it follows, and register the file in the table above — the skill's `SKILL.md` rule points at this index, not at individual files.
