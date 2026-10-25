# Code conventions — JavaScript / TypeScript

**Applies to:** all `.js`, `.ts`, `.jsx`, `.tsx` code.
**Upstream reference:** [TypeScript Style Guide](https://mkosir.github.io/typescript-style-guide/).
**Precedence:** the project's own `.claude/CLAUDE.md` wins where it conflicts with this file.

## Naming

| Element | Convention |
|---|---|
| Classes | `PascalCase` |
| Types | `PascalCase` |
| Generic type parameters | `T`, or descriptive `TPascalCase` (`TSession`) |
| Error classes | suffix `Error` — `ValidationError` |
| Interfaces | `IPascalCase` (prefix `I`) — see *Prefixed types* |
| Enums | `EPascalCase` (prefix `E`) — see *Prefixed types* |
| Public functions/methods | `camelCase` |
| Private/protected functions/methods | `_camelCase` (leading underscore) |
| Lifecycle methods | `camelCase` (framework default) |
| Local/public variables | `camelCase` |
| Private/protected variables | `_camelCase` |
| Booleans (any scope) | `is`/`has`/`can`/`should` prefix — `isReady`, `hasPayload`, `canRetry`, `shouldFlush` |
| Constants | `UPPER_SNAKE_CASE` |
| Local/public callbacks | `camelCase` |
| Private/protected callbacks | `_camelCase` |
| Event callbacks | `on*` / `_on*` |
| Handlers | `*Handler` suffix — `submitHandler`, `_errorHandler` |
| JSON fields | `camelCase` |

### Prefixed types

`I` and `E` are prefixes, not part of the name: write the prefix, then the type's own PascalCase name.

- Interfaces: `IDataService`, `IWorkerQueue`, `IUserRepository` — never `Idataservice`, never a bare `DataService`.
- Enums: `EOrderStatus`, `EPaymentMethod` — never `Eorderstatus`, never a bare `OrderStatus`. Members are `PascalCase`, unprefixed.
- The acronym rule below applies to the name *after* the prefix: `IIOHandler`, `IUidStore`, `EIOMode`.

### Acronyms and short words

Applies inside any identifier, whatever its casing:

- 2 characters or fewer → all uppercase: `userID`, `readIO`, `dbIO`.
- 3 characters or more → PascalCase, never all-caps: `Uid`, `Http`, `Json` — `userUid`, `parseJson`, `HttpClient`.

The first segment of a `camelCase` or `_camelCase` identifier still starts lowercase, so a leading acronym is lowercased: `id`, `_id`, `uid`, `httpClient`. The rule applies from the second segment onward.

### Name length

Distinct from the acronym rule above: this is about how much of a *word* to keep. A short name is good when it still carries the full meaning; a longer name is better when the short one would leave the reader guessing. Judge by how far the reader is from the declaration:

- A name whose declaration is one or two lines away can be short: `i` for a loop index, `e` for an event in a one-line handler, `ctx`, `err`, `idx`.
- The wider the scope, the more the name has to carry. An exported symbol, a class member, or a value used dozens of lines below its declaration gets full words — `retryDelayMs`, not `rd`.
- Never shorten to the point of ambiguity. `cnt` could be count or counter; `res` could be response, result, or resource; `val` says nothing about what the value is. If a reader has to scroll back to learn what a name means, the name is too short.
- Prefer dropping redundancy over truncating words: on a `Wallet` class, the member is `balance`, not `walletBalance` and not `wltBal`.
- Functions name what they do with a verb: `loadPlayerProfile`, not `lpp` or `doProfile`.

## Language guidelines

- Use const assertions for type safety and immutability.
- Strive for data immutability — `Readonly`, `ReadonlyArray`.
- Make most object properties required; use optional properties sparingly.
- Use discriminated unions.
- Avoid type assertions; define proper types instead.
- Keep functions pure, stateless, and single-responsibility.
- Use named exports.
- Organize code by feature; collocate related code as closely as possible.

## Layout and comments

- **Comments:** rare — only a non-obvious *why* (constraint, workaround, gotcha). One short line written the way a teammate would say it — plain, natural words, not keyword shorthand or AI-polished prose: `// Upstream drops the first connection, so retry once.` Never restate the code, narrate steps, log edits (`// added`, `// fixed`, `// now uses X`), or leave filler.
- JSDoc/TSDoc only where an exported symbol's contract is non-obvious from its name and types; one line where possible.

## House rules that depart from upstream

- The `I` prefix on interfaces and the `E` prefix on enums are house rules; the upstream guide uses bare PascalCase for both.
- The acronym rule gives `Uid`/`Http`/`Json` where much TypeScript code writes `UUID`/`HTTP`/`JSON`.

Apply both consistently. Everything else in this file follows upstream.
