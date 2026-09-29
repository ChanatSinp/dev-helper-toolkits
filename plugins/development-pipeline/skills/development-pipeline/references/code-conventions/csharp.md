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
| Booleans (any scope) | `is`/`has` prefix — `IsValid`, `hasPayload` |
| Callbacks | follow the member's own casing — `PascalCase` public, `_camelCase` private/internal |
| Event callbacks | `On*` prefix — `OnOrderPlaced`; `_on*` when private/internal |
| Handlers | `*Handler` suffix — `SubmitHandler`, `_errorHandler` |
| Primary constructor parameters — `class`/`struct` | `camelCase` |
| Primary constructor parameters — `record` | `PascalCase` (they become public properties) |
| Generic type parameters | `T`, or descriptive `TPascalCase` (`TSession`) |
| Attribute types | suffix `Attribute` |

- No two consecutive underscores — those names are reserved for the compiler.
- Namespaces use reverse domain name notation.
- Avoid single-letter names outside loop counters; prefer clarity over brevity.

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
- `//` for brief explanations, on its own line, sentence-cased and ending with a period, one space after the delimiter. Avoid `/* */`.
- XML doc comments for all public members, classes, methods, and fields.

## House rules that depart from upstream

- The `E` prefix on enums is a house rule; Microsoft uses no type prefix on enums. (The `I` prefix on interfaces is Microsoft's own convention.)
- The acronym rule gives `Uid`/`Http`/`Json` where .NET writes `UUID`/`HTTP`/`JSON`.

Apply both consistently. Everything else in this file follows Microsoft.
