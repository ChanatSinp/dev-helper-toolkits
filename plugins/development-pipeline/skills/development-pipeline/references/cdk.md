# AWS CDK work

Read before executing any `cdk`-owned phase or fixing a CDK file — a stack, construct, CDK app entry, or `cdk.json`. It adds to the implementer's own rules; where the two differ, this file wins for CDK code. Before editing files in the CDK directory (e.g. `infra/`, `cdk/`), read its `.claude/CLAUDE.md` if one exists.

## Implementation

- **Match the project.** Use the CDK app's existing language, CDK major version (v2, `aws-cdk-lib`), construct style, and stack layout; read `cdk.json` for the app entry and context. For a new CDK app, use TypeScript unless the plan says otherwise.
- Follow the plan exactly: no extra resources. If a step is ambiguous — instance size, retention, an account/region, a resource name the plan does not fix — stop and return the question.
- **CDK practice, unless the plan or project says otherwise:**
  - Prefer L2 constructs; drop to L1 (`Cfn*`) only where no L2 covers the need.
  - Grant access with `grant*` methods and least-privilege policies; never `*` actions or resources unless the plan requires it and says why.
  - Never hardcode secrets, account IDs, or ARNs of other environments. Take environment from `env`/context/props, secrets from Secrets Manager or SSM references.
  - Stateful resources (databases, buckets, tables, queues with data) keep an explicit `removalPolicy` and keep their logical IDs: never rename or move a construct in a way that changes an existing resource's logical ID unless the plan explicitly calls for replacement.
  - Encryption at rest, blocked public access on buckets, and log retention set explicitly.
  - Cross-stack values pass as props, not as hardcoded exports.
- CDK assertion and snapshot tests are unit tests — written only under `references/unit-tests.md`, when your brief carries it. Running the existing ones is yours.

## AWS boundary — hard rules

- **Never run `cdk deploy`, `cdk bootstrap`, `cdk destroy`, `cdk import`, `cdk watch`, or `cdk migrate`, or any AWS CLI/SDK call that writes.** This holds even when the plan or brief asks: hand the command back instead.
- `cdk synth` needs no deployment. Run it, always with `-o <root>/.claude/temp/cdk.out` (`<root>` the absolute project root, even inside a `(cd infra && ...)` wrapper; in package mode `.../cdk.out/<package>`, so concurrent packages never share it). Write nothing else under `.claude/temp/` — no copies of synth output. If synth fails only because a context lookup (VPC, AMI, hosted zone) needs credentials that are not available, report that instead of faking the lookup or committing invented values to `cdk.context.json`.
- Run `cdk diff` only when your brief says `diff stage: <non-prod stage>, credentials available`; never against production. With `no diff credentials`, skip it and say so.

## Documentation

Stack-level detail goes in the CDK directory's own `.claude/CLAUDE.md`, with a one-line pointer from the root `.claude/CLAUDE.md` (entry point, stacks, how to synth). In package mode, put this in your "documentation needed" note instead.

## Handback additions

The synth result per stack; the diff summary (or why it was not run) with every replaced or destroyed resource called out; any `cdk.context.json` change, by key; and the exact deploy commands for the user to run (`npx cdk deploy <Stack> --context ...`), including whether `cdk bootstrap` is needed first.
