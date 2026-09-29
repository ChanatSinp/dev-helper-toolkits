# Code conventions — Go

**Applies to:** all `.go` code.
**Upstream reference:** [Effective Go](https://go.dev/doc/effective_go), [Go Code Review Comments](https://go.dev/wiki/CodeReviewComments), [Google Go Style Guide](https://google.github.io/styleguide/go/).
**Precedence:** the project's own `.claude/CLAUDE.md` wins where it conflicts with this file.

## Naming

| Element | Convention |
|---|---|
| Packages | lowercase, single word, no underscores or mixedCaps (`http`, `wallet`) |
| Files | `snake_case.go`; `_test.go` suffix for tests |
| Exported identifiers — types, functions, methods, fields, constants | `PascalCase` |
| Unexported identifiers | `camelCase` — no leading underscore |
| Interfaces | `IPascalCase` (prefix `I`) — see *Prefixed types* |
| Local variables, parameters | `camelCase` |
| Booleans (any scope) | `is`/`has` prefix — `isReady`, `hasPayload`; bare `ok` and `found` stay idiomatic |
| Callbacks | follow the identifier's own casing — `PascalCase` exported, `camelCase` unexported |
| Event callbacks | `On*` / `on*` prefix — `OnOrderPlaced`, `onRetry` |
| Handlers | `*Handler` suffix — `SubmitHandler`, `errorHandler` |
| Method receivers | one or two characters, consistent across every method on the type (`s *Server`) |
| Sentinel errors | `ErrPascalCase` (`ErrNotFound`) |
| Error types | `PascalCaseError` (`ValidationError`) |
| Getters | no `Get` prefix — `Owner()`, not `GetOwner()` |
| Struct tags / JSON fields | `camelCase` |

Go has no `public`/`private` keywords: the first letter's case *is* the access modifier. Do not carry the leading-underscore convention from other languages into Go.

Go has no enum type, so the `E` prefix used in the other house conventions does not apply. Model an enum as a named type with `PascalCase` typed constants, grouped in one `const` block.

### Prefixed types

`I` is a prefix, not part of the name: write `I` followed by the interface's own PascalCase name — `IDataService`, `IWalletRepository`. Never `Idataservice`, never a bare `DataService`. The acronym rule below applies to the name after the prefix: `IIOHandler`, `IUidStore`.

Keep interfaces small and define them where they are consumed, not beside the implementation.

### Acronyms and short words

Applies inside any identifier, whatever its casing:

- 2 characters or fewer → all uppercase: `userID`, `readIO`, `dbIO`.
- 3 characters or more → PascalCase, never all-caps: `Uid`, `Http`, `Json` — `userUid`, `parseJson`, `HttpClient`.

The first segment of an unexported (`camelCase`) identifier still starts lowercase: `id`, `uid`, `httpClient`. The rule applies from the second segment onward.

### Short names

Distinct from the acronym rule above: this is about how much of a *word* to keep. Short names are idiomatic in Go and preferred over long ones — but only where the meaning survives. Judge by how far the reader is from the declaration:

- A name whose declaration is one or two lines away can be a single letter: `i` for a loop index, `r` for a reader, `b` for a buffer, `err` for an error, `ctx` for a context.
- The wider the scope, the more the name has to carry. A package-level variable, an exported field, or a value used dozens of lines below its declaration gets a full word.
- Never shorten to the point of ambiguity. `cnt` could be count or counter; `res` could be response, result, or resource; `val` says nothing about what the value is. If a reader has to scroll back to learn what a name means, the name is too short.
- Prefer dropping redundancy over truncating words: inside `package wallet`, the type is `wallet.Balance`, not `wallet.WalletBalance`, and a local is `bal`, not `wltBal`.

## Language guidelines

- Return errors, don't panic. Wrap with `fmt.Errorf("...: %w", err)` to keep the chain; compare with `errors.Is`/`errors.As`.
- Handle every error at the point it is returned — never assign to `_` to silence one.
- `context.Context` is the first parameter, named `ctx`, and is never stored in a struct.
- Accept interfaces, return concrete types.
- Zero values should be usable; avoid constructors that only fill defaults.
- Guard clauses over nested `if`/`else` — keep the happy path at the leftmost indentation.
- `defer` for cleanup, immediately after the acquiring call.

## Layout and comments

- Format with `gofmt`; the formatter's output is not up for debate.
- Doc comments start with the identifier's own name: `// Balance returns the current balance.`
- Every exported identifier has a doc comment; each package has one package comment.
- Full sentences, ending with a period.

## House rules that depart from upstream

- The `I` prefix on interfaces is a house rule; Go idiom is a bare noun or an `-er` name (`Reader`, `Store`).
- The acronym rule gives `Uid`/`Http`/`Json` where Go and its standard library write `UID`/`HTTP`/`JSON`. This is the most visible deviation in Go code — apply it anyway, consistently.

Everything else in this file follows upstream Go.
