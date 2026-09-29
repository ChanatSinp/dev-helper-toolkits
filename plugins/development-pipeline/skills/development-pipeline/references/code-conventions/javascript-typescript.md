# Code conventions — JavaScript / TypeScript

**Applies to:** all `.js`, `.ts`, `.jsx`, `.tsx` code.
**Upstream reference:** [TypeScript Style Guide](https://mkosir.github.io/typescript-style-guide/).
**Precedence:** the project's own `.claude/CLAUDE.md` wins where it conflicts with this file.

## Naming

| Element | Convention |
|---|---|
| Classes | `PascalCase` |
| Types | `PascalCase` |
| Interfaces | `IPascalCase` (prefix `I`) — see *Prefixed types* |
| Enums | `EPascalCase` (prefix `E`) — see *Prefixed types* |
| Public functions/methods | `camelCase` |
| Private/protected functions/methods | `_camelCase` (leading underscore) |
| Lifecycle methods | `camelCase` (framework default) |
| Local/public variables | `camelCase` |
| Private/protected variables | `_camelCase` |
| Booleans (any scope) | `is`/`has` prefix — `isReady`, `hasPayload` |
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

## Language guidelines

- Use const assertions for type safety and immutability.
- Strive for data immutability — `Readonly`, `ReadonlyArray`.
- Make most object properties required; use optional properties sparingly.
- Use discriminated unions.
- Avoid type assertions; define proper types instead.
- Keep functions pure, stateless, and single-responsibility.
- Use named exports.
- Organize code by feature; collocate related code as closely as possible.

## House rules that depart from upstream

- The `I` prefix on interfaces and the `E` prefix on enums are house rules; the upstream guide uses bare PascalCase for both.
- The acronym rule gives `Uid`/`Http`/`Json` where much TypeScript code writes `UUID`/`HTTP`/`JSON`.

Apply both consistently. Everything else in this file follows upstream.
