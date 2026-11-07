# Covenant Control

**Atomic incident response and allocation operations, enforced by Fe.**  A working, local-only prototype for the [Fe Builders Challenge 2026](https://fe-lang.org/contest/).

> **The problem:** In protocol operations, an incident can require simultaneously reducing one market's exposure, protecting unallocated capacity, and keeping several correlated limits valid. Executing separate updates can strand the system in an unsafe state; relying only on an off-chain planner leaves the operator's exact incident objective unprotected at commitment.
>
> **Our solution:** An operator enters an incident objective, compares three possible responses, and commits one Fe-attested, atomic outcome. Fe checks every ordered operation, the final policy, the exact response target, and the incident's exposure/reserve requirements **inside the transaction**.

**No real assets, external oracle feeds, wallet connection, or public chain.** The application deploys Fe bytecode into an isolated EthereumJS EVM with disposable sample keys. This is a demonstration prototype; Fe itself is not production-ready.

## Try the core result in one command

**Requirements:** Fe **26.5.0**, Node **20+**, npm and internet access for the first locked npm dependency install. Fe installation: [official guide](https://fe-lang.org/getting-started/installation/). On Windows, PowerShell 7 is supported, and the original pinned `RUN_WINDOWS.ps1` remains available.

From this repository:

```sh
node scripts/reproduce.mjs
```

This command verifies source hashes and the independent audit export; runs **34 Fe tests**, compiles the deployable bytecode and ABI, confirms the compiler rejects an unsafe external call with `16-0001`, runs the **31 Node/EVM/HTTP tests**, and executes a short adversarial **Fe incident witness**. The witness outputs `results/JUDGE_DEMO.json` (generated locally).

If Fe is not on `PATH`, set `FE_EXE` to an installed Fe 26.5.0 binary. In PowerShell, for example:

```powershell
$env:FE_EXE = "$HOME\Downloads\FE_PROGRESSIVE_DECISIVE_GATE\toolchain\fe.exe"
node scripts/reproduce.mjs
```

**Then launch the interface:**

```sh
npm start
```

Visit **http://127.0.0.1:4549** and choose **Incident response**. Stop with Ctrl+C. The contract state resets on every server restart, while the local JSONL audit persists and clearly separates sessions.

For an offline/static handoff check (no Fe or npm packages):

```sh
node scripts/reproduce.mjs --check
```

> **Dependency note:** This repository includes the exact `package-lock.json` generated on the entrant's Windows machine and verified using a clean `npm ci` installation. The lockfile pins transitive npm dependencies. For a clean checkout, `node scripts/reproduce.mjs` selects `npm ci` when dependencies are missing. The Windows `RUN_WINDOWS.ps1` launcher uses `npm install` if it needs to install packages; the separately completed release gate exercised `npm ci`.

## The five-minute demo

Start from `v1 · Core 400 / Supporting 300 / Satellite 100`; total budget is 1,000, so 200 is unallocated.

1. In **Incident response**, select **Core risk · 200 limit** and compare the Fe-validated responses: Keep capacity active (`200/500/100`), Spread remaining exposure (`200/353/247`), and Build protective reserve (`200/300/100`).
2. Choose **Build protective reserve**. Confirm both the normal Fe policy mask and the independent Fe incident mask are `0`; commit with the disposable authorized operator. The result is `v2 · 200/300/100`, with 400 unallocated.
3. Reassess the same alert: **ALREADY CONTAINED**, no transaction. Enter a 950-unit reserve: **OBJECTIVE UNREACHABLE**, no transaction. Switch to the untrusted reviewer: the contract denies commitment.
4. Inspect **Local EVM history**. It records the incident objective, strategy, Fe verdict, transaction hash, gas, before/after state, and hash-linked local journal.

The **non-UI adversarial witness** (`node scripts/demo.mjs`, after compilation and npm installation) demonstrates a more important boundary: a candidate that passes ordinary protocol policy but **violates Core's incident limit** reverts on the Fe incident-specific commit path. A plan demanding too much reserve or declaring a false exact target likewise reverts without changing the contract version.

## Why Fe matters

The implementation is **not merely a Solidity-equivalent policy check with a Fe frontend**:

- `contracts/CovenantControl.fe` uses Fe's **projection-yield scoped edit** (`Policy.guarded_edit`) to enforce final-state invariants at scope exit, including early returns. Intermediate cross-field violations can exist *inside one transaction* but are never committed as final state.
- Fe's **explicit effects/access model** rejects a raw external call while a mutable storage access is held open; `contracts/IllegalCall.negative.fe` must fail compilation with diagnostic `16-0001`.
- `previewActions()` and `commitIncidentActions()` use the **same Fe-defined operation semantics**, not a JavaScript replica of the resource rules.
- `previewIncidentActions()` and `commitIncidentActions()` independently verify the supplied incident maximum, reserve minimum, and exact terminal allocation, not just the planner's proposed plan.

See [the project manifest](PROJECT_MANIFEST.md), [architecture and trust boundaries](docs/ARCHITECTURE.md) and [the judge's fastest reproduction path](docs/JUDGE_START_HERE.md).

## What is actually verified?

- **Owner's Windows v1.7.1 run:** 34 Fe tests and 31 Node/EVM/HTTP tests passed, followed by a successful browser-initiated Fe-attested incident commitment at **v1 → v2**. The local receipt used **52,442 gas**.
- **Shipped owner evidence:** `evidence/owner-v17-local-audit.json`, exactly the owner-provided sandbox export. Run `node scripts/verify-evidence.mjs` to check its digest chain and internal outcome consistency. This is **not an independent blockchain proof**; local files can be rewritten together.
- **v1.8 Windows release acceptance (November 7, 2026):** The entrant verified the original v1.8 archive SHA-256, all 38 manifest-tracked files, **34/34 Fe tests**, compiler diagnostic `16-0001`, **31/31 Node/EVM/HTTP tests**, the independent incident witness, and the local EVM server. A separate lockfile release gate confirmed **`npm ci` PASS**, the same 31/31 integrated tests and the independent witness. The exact source ZIP and original lockfile SHA-256 are recorded in [the v1.8 acceptance note](evidence/V1_8_REPRO_STATUS.md). These are entrant-observed local results, **not an independently audited production deployment**.

## Project map

| Location | Purpose |
|---|---|
| `contracts/CovenantControl.fe` | The core Fe contract, operations, scoped invariant, 34 Fe tests |
| `contracts/IllegalCall.negative.fe` | Compiler-enforced access conflict negative test |
| `app/chain.mjs` | EthereumJS isolated deployment and Fe ABI calls |
| `app/lib/incident.mjs` | Candidate response construction and Fe preview comparison |
| `app/server.mjs` | Local API, atomic commit orchestration, journal integration |
| `app/public/` | Seven-view operator workspace |
| `app/tests/` | 31 Node/EVM/HTTP/audit/planner/incident tests |
| `scripts/reproduce.mjs` | Cross-platform clean-room verification and witness |
| `scripts/demo.mjs` | Minimal adversarial incident demonstration |
| `scripts/verify-evidence.mjs` | SHA-256 journal and recorded-outcome cross-check |
| `docs/` | Judge guide, architecture, trust scope, provenance, submission checklist |
| `evidence/` | Owner-observed acceptance, SHA-256-linked local audit, and reproduced v1.8 witness |

**MIT license.** [License](LICENSE) · [Responsible disclosure of AI assistance/reuse](docs/PROVENANCE_AI.md) · [Limitations](docs/SECURITY_LIMITATIONS.md)
