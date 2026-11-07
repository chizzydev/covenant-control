# Covenant Control v1.6 — accepted local incident-response evidence

On November 7, 2026, the owner ran the v1.6 integration suite: **26/26 Node tests passed** and the application reported `COVENANT_LOCAL_EVM=READY`. The owner then completed a browser-level incident-response workflow and exported its local audit JSON.

* Initial local state: **v1, Core 400 / Supporting 300 / Satellite 100**, 200 unallocated.
* Operator-entered incident: **Core maximum 200**, reserve minimum **200**.
* Fe-checked alternatives: keep allocation active; spread exposure; build protective reserve.
* Reviewer role was blocked from commitment; authorized operator selected **Build protective reserve**.
* Exactly one signed local transaction committed **v1 → v2**, with **Core 200 / Supporting 300 / Satellite 100**, leaving **400 unallocated**; **51,741 local gas**.
* The JSON record reports `policyMask=0`, `operationError=0`, and the exact goal. The browser reported `ALREADY CONTAINED` when the incident was reassessed, and `OBJECTIVE UNREACHABLE` for a 950-unit reserve request; neither produced a transaction.
* The export has **two hash-linked journal entries** (session + one transaction). This is a local, rewriteable log and is **not** public-chain or tamper-proof evidence.

The incident-specific limits in v1.6 were checked at server assessment and reassessment, but were not checked again **inside the Fe contract**. This is the architectural gap addressed by v1.7. The owner's actual exported JSON is intentionally not included in this distributable project.
