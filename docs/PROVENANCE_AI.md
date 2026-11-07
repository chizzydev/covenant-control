# Provenance, pre-existing work, and AI disclosure

## Competition window

The Fe Builders Challenge allows preparatory research before November 3, 2026, but evaluates only substantial new work completed during November 3–24. Covenant Control's app-level implementation and iterative vertical slices were developed during the competition window, beginning November 7, 2026, after earlier Fe-language feasibility investigations. Those preparatory feasibility experiments explored scoped edit semantics, typed oracle-rate prototypes, transient storage, and other alternatives; the final application is a distinct new build.

## AI use

The project's source, tests, local tools, UI, documentation and development/release iterations were drafted and revised extensively with ChatGPT assistance. The human entrant defined priorities, ran the pinned Fe toolchain and Node/EVM suites on Windows, inspected the application, completed browser acceptance tests, and supplied the local execution evidence. AI-generated changes were tested and corrected in response to actual compiler and integration failures. The project should not be represented as fully hand-written or independently security-audited.

## External libraries / reuse

- Fe 26.5.0 standard library, compiler, test/runtime mechanisms (`argotorg/fe`), used as dependencies, **not** modified or resubmitted as original source.
- EthereumJS VM/Common/Tx/Util and ethers provide isolated local EVM execution and ABI integration, with their own upstream licenses.
- Node.js standard libraries provide the local HTTP server, CLI verification, SHA-256 journal, and tests.
- No external proprietary protocol's source was copied into Covenant Control. Existing practices (atomic updates, versioning, budgets, risk limits) are general design background; the Fe contract and application workflow are the project's implementation.

## Acceptance evidence

The supplied `evidence/owner-v17-local-audit.json` is an actual sandbox export shared by the owner from the Windows Fe/EVM run, not AI-fabricated or a public blockchain record. It uses fully synthetic, disposable test accounts and contains no funded keys. Its SHA-256 record links can be rechecked using `node scripts/verify-evidence.mjs`.

This document is a draft provenance declaration intended for the actual submitting human to review for factual accuracy before publishing. Any additional reused assets or contributions must be disclosed by the entrant.
