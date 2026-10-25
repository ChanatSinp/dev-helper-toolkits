# Code conventions — C#

**Applies to:** all `.cs` code.
**Upstream reference:** Microsoft Learn — [Identifier names](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/identifier-names), [Coding conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions).
**Precedence:** the project's own `.claude/CLAUDE.md` wins where it conflicts with this file.

## Naming

| Element | Convention |
|---|---|
| Namespaces, types (class, struct, record, delegate) | `PascalCase` |
| Interfaces | `IPascalCase` (prefix `I`) — see *Prefixed types* |
| Enum types | `EPascalCase` (prefix `E`) — see *Prefixed types*; singular noun, plural for `[Flags]` |
| Public/protected members — methods, properties, events, fields | `PascalCase` |
| Local functions | `PascalCase` |
| Private/internal instance fields | `_camelCase` (leading underscore) |
| Private/internal static fields | `s_camelCase`; `[ThreadStatic]` uses `t_camelCase` |
| Constants (fields and locals, any access modifier) | `PascalCase` |
| Method parameters, local variables | `camelCase` |
| Booleans (any scope) | `is`/`has`/`can`/`should` prefix — `IsValid`, `hasPayload`, `CanRetry`, `shouldFlush` |
| Callbacks | follow the member's own casing — `PascalCase` public, `_camelCase` private/internal |
| Event callbacks | `On*` prefix — `OnOrderPlaced`; `_on*` when private/internal |
| Handlers | `*Handler` suffix — `SubmitHandler`, `_errorHandler` |
| Primary constructor parameters — `class`/`struct` | `camelCase` |
| Primary constructor parameters — `record` | `PascalCase` (they become public properties) |
| Generic type parameters | `T`, or descriptive `TPascalCase` (`TSession`) |
| Attribute types | suffix `Attribute` |
| Async methods (return `Task`/`ValueTask`) | suffix `Async` — `LoadPlayerAsync` |
| Exception types | suffix `Exception` — `InsufficientFundsException` |
| Event-args types | suffix `EventArgs` — `OrderPlacedEventArgs` |

- No two consecutive underscores — those names are reserved for the compiler.
- Namespaces use reverse domain name notation.

### Prefixed types

`I` and `E` are prefixes, not part of the name: write the prefix, then the type's own PascalCase name.

- Interfaces: `IDataService`, `IWorkerQueue`, `IUserRepository` — never `Idataservice`, never a bare `DataService`.
- Enums: `EOrderStatus`, `EPaymentMethod` — never `Eorderstatus`, never a bare `OrderStatus`. Members are `PascalCase`, unprefixed.
- The acronym rule below applies to the name *after* the prefix: `IIOHandler`, `IUidStore`, `EIOMode`.

### Acronyms and short words

Applies inside any identifier, whatever its casing:

- 2 characters or fewer → all uppercase: `UserID`, `ReadIO`, `DbIO`.
- 3 characters or more → PascalCase, never all-caps: `Uid`, `Http`, `Json` — `UserUid`, `ParseJson`, `HttpClient`.

The first segment of a `camelCase` or `_camelCase` identifier still starts lowercase, so a leading acronym is lowercased: `id`, `_id`, `uid`, `httpClient`. The rule applies from the second segment onward.

Use abbreviations only where widely accepted — the rule governs how to case the ones you keep, not a licence to invent them.

### Name length

Distinct from the acronym rule above: this is about how much of a *word* to keep. A short name is good when it still carries the full meaning; a longer name is better when the short one would leave the reader guessing. Judge by how far the reader is from the declaration:

- A name whose declaration is one or two lines away can be short: `i` for a loop index, `e` for an event in a one-line handler, `ctx`, `err`, `idx`.
- The wider the scope, the more the name has to carry. A public member, a field, or a value used dozens of lines below its declaration gets full words — `RetryDelayMs`, not `Rd`.
- Never shorten to the point of ambiguity. `cnt` could be count or counter; `res` could be response, result, or resource; `val` says nothing about what the value is. If a reader has to scroll back to learn what a name means, the name is too short.
- Prefer dropping redundancy over truncating words: on a `Wallet` class, the property is `Balance`, not `WalletBalance` and not `WltBal`.
- Functions name what they do with a verb: `LoadPlayerProfile`, not `Lpp` or `DoProfile`.

## Language guidelines

- Use language keywords for types, not runtime types: `string` not `System.String`, `int` not `System.Int32`. Prefer `int` over unsigned types.
- Use `var` only when the type is obvious from the right-hand side (a `new`, an explicit cast, a literal). Use it for `for` loop variables and LINQ query/range variables; use explicit types in `foreach`.
- Prefer modern constructs: collection expressions, raw string literals, string interpolation (`StringBuilder` for loops), target-typed `new`, object initializers, `required` properties over forcing initialization through constructors.
- `Func<>`/`Action<>` instead of custom delegate types.
- Catch only exceptions you can handle — never bare `System.Exception` without a filter; use specific exception types with meaningful messages.
- `using` statement (brace-less form) instead of `try`/`finally` whose `finally` only disposes.
- `&&`/`||`, never `&`/`|`, in comparisons.
- `async`/`await` for I/O-bound work; `Task.ConfigureAwait` where deadlocks are a risk.
- LINQ for collection manipulation; meaningful query variable names, `where` before other clauses, aliases so anonymous-type properties stay `PascalCase`.
- Call static members through the class name (`ClassName.StaticMember`), never through a derived class.
- File-scoped namespace declarations; `using` directives outside the namespace.

## Layout and comments

- Four spaces, no tabs. Allman braces (open and close each on their own line, aligned to the current indent).
- One statement and one declaration per line; blank line between method and property definitions.
- Parentheses to make expression clauses explicit; line breaks before binary operators.
- `//` on its own line, one space after the delimiter. Avoid `/* */`.
- **Comments:** rare — only a non-obvious *why* (constraint, workaround, gotcha). One short line written the way a teammate would say it — plain, natural words, not keyword shorthand or AI-polished prose: `// Upstream drops the first connection, so retry once.` Never restate the code, narrate steps, log edits (`// added`, `// fixed`, `// now uses X`), or leave filler.
- Methods carry an XML doc comment that covers their parameters: a one-line `<summary>`, a `<param>` for every parameter (what it means, units, allowed range, or null handling — not its type), and `<returns>` when non-void. Same natural, short wording as other comments:
  ```csharp
  /// <summary>Charges the player's wallet for one spin.</summary>
  /// <param name="playerID">Player to charge; must already have an open session.</param>
  /// <param name="amount">Bet in minor units (cents); zero is rejected.</param>
  /// <returns>Balance after the charge.</returns>
  ```
  Other members (properties, fields, types) get one only where their purpose is non-obvious from the name.

## House rules that depart from upstream

- The `E` prefix on enums is a house rule; Microsoft uses no type prefix on enums. (The `I` prefix on interfaces is Microsoft's own convention.)
- The acronym rule gives `Uid`/`Http`/`Json` where .NET writes `UUID`/`HTTP`/`JSON`.

- Every method documents its parameters with `<param>` tags; Microsoft recommends XML docs only for public APIs.

Apply all three consistently. Everything else in this file follows Microsoft.
