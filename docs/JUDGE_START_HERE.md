# Covenant Control — judge's five-minute route

**Submission:** Fe Builders Challenge 2026. **Core technical contribution:** `contracts/CovenantControl.fe`. **Compiler:** Fe 26.5.0. **License:** MIT. **Scope:** synthetic allocations, local in-memory EVM only.

## 30-second pitch

When a protocol faces a market-risk incident, operators must choose how to reduce exposure without violating resource constraints or relying on an unverified sequence of manual transactions. Covenant Control compares three risk responses, lets the operator choose the trade-off, and executes the chosen response atomically. Fe itself enforces the final policy, the ordered operation preconditions, the exact terminal target, and the *incident-specific* exposure and reserve bounds.

## One terminal command

```
node scripts/reproduce.mjs
```

Prerequisites: Fe 26.5.0 on `PATH` (or `FE_EXE` pointing to it), Node 20+, npm, first-install network. This runs 34 Fe tests, negative compiler check `16-0001`, deployable bytecode build, 31 Node tests, and an independent adversarial witness. The clean-room tool prints `REPRODUCTION=PASS` only after each stage succeeds. The committed `package-lock.json` pins direct and transitive npm dependencies; a clean checkout selects `npm ci`.

In a browser: `npm start` → http://127.0.0.1:4549 → **Incident response**.

## The distinctive demonstration

The initial state is Core 400 / Supporting 300 / Satellite 100. An operator enters `Core <= 200` and minimum reserve `200`.

| Response | Final Core / Supporting / Satellite | Deployed | Reserve | Trade-off |
|---|---|---:|---:|---|
| Keep active | 200 / 500 / 100 | 800 | 200 | Retain deployment |
| Spread | 200 / 353 / 247 | 800 | 200 | Lower concentration |
| Protective reserve | 200 / 300 / 100 | 600 | 400 | Retire exposure |

All three are proposed off-chain, then checked by the same compiled Fe contract. Commit the **protective reserve** option, which retires 200 from Core. One EVM transaction yields v2 and 200/300/100.

**The adversarial proof judges should inspect:** A different plan yields 250/450/100, which satisfies permanent policy but violates incident Core <= 200. `scripts/demo.mjs` invokes `commitIncidentActions()` directly and confirms the transaction reverts and all on-chain state remains v1. That demonstrates the new incident attestation cannot be bypassed merely by skipping the UI or planner when using this entry point.

## The Fe-specific core (read in this order)

1. `fn Policy::guarded_edit` in `contracts/CovenantControl.fe`: a projection that yields a mutable candidate and validates the final invariant when the scope ends.
2. `fn apply_action` / `fn stage_actions`: ordered transfer/retire/issue/assert operations; intermediate policy violations are diagnostic, but impossible operations are never allowed.
3. `fn incident_violations` and the `previewIncidentActions` / `commitIncidentActions` message handlers: extra supplied incident max, reserve, and exact target assertions performed by Fe at the final transaction boundary.
4. `contracts/IllegalCall.negative.fe`: `fe check` must reject an external call while mutable storage access is open, diagnostic `error[16-0001]`.
5. `app/chain.mjs`: the browser never reimplements Fe's policy. It runs the Fe bytecode in EthereumJS EVM and decodes its results.

## Evidence and limits

- `evidence/owner-v17-local-audit.json`: actual owner's local execution, not a public-chain receipt. Run `node scripts/verify-evidence.mjs` to independently recompute the SHA-256 record chain. Result: one successful incident tx, 52,442 gas, Fe incident mask 0, exact target match, v1 to v2.
- `docs/SECURITY_LIMITATIONS.md`: role selector is not authentication; risk alert is operator-entered; generic commit entry points bypass any persistent incident lock; not production-ready; no external security audit; no external funds.
- `docs/PROVENANCE_AI.md`: AI assistance and pre-existing work disclosure.

**If you have only three minutes:** read `guarded_edit`, the incident contract branch, and `scripts/demo.mjs` (or run the single reproduction command). Then click through Incident Response once.
