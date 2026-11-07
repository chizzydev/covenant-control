# v1.7.1 — owner-observed browser acceptance (November 7, 2026)

The owner ran `COVENANT_CONTROL_V1_7_1` in Windows PowerShell 7 with Fe 26.5.0. The fail-closed launcher reached `COVENANT_LOCAL_EVM=READY` after its 34 Fe tests, bytecode build, compiler access-conflict check, and **31/31 Node/EVM/HTTP tests** passed.

The owner then used the browser **Incident response** workspace with a synthetic Core risk limit of 200 and required reserve of 200, selected **Build protective reserve**, and committed the new Fe incident-attested entry point. History and the unmodified exported audit JSON confirm:

- **Before:** `v1 · 400 / 300 / 100` with 200 unallocated.
- **Action:** retire 200 from Core (opcode 9).
- **After:** `v2 · 200 / 300 / 100` with 400 unallocated.
- **Fe policy mask:** 0.
- **Independent Fe incident mask:** 0, with `feIncidentGoalMatches=true`.
- **Fe action path:** `previewIncidentActions()` EVM static call and `commitIncidentActions()` signed local EVM transaction.
- **Result:** one committed local EVM transaction, 52,442 gas, no EVM exception.
- **Tx hash:** `0x8cd7a15163ec7751c7acf5c3b9fb978ce93483414b2ef9fb5ff575d34f12eaa9` (local EVM only).
- **Audit journal:** two linked entries (one session, one transaction) from one local EVM session.

Run `node scripts/verify-evidence.mjs evidence/owner-v17-local-audit.json` to recompute SHA-256 linkage and cross-check the committed target and Fe verdict. It does **not** establish that these fields came from a public blockchain or provide malicious-tamper resistance.

The v1.6 browser demonstration independently covered the three alternative responses, an unauthorized reviewer, Already Contained, and an impossible reserve request. The v1.7.1 supplied screenshot and audit explicitly establish the newly added Fe incident-specific commit path. The automated v1.7.1 suite covers direct adverse incident scenarios; those are not described as separate manual browser executions.
