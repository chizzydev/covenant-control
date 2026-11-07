# Submission draft — verify details with entrant before pasting

**Project name:** Covenant Control

**Category:** One open-pool Fe Builders Challenge entry (no separate tracks).

**Short pitch:** Covenant Control is an incident-response desk for protocols managing coupled capacity limits. An operator enters a risk objective, compares feasible responses, and commits a selected plan atomically. Fe guards each ordered operation, final policy invariants, the exact terminal target, and the supplied incident exposure/reserve constraints.

**Fe-specific highlight:** Fe's projection-yield `guarded_edit()` enforces a postcondition when the edit scope ends. Ordered operations may temporarily violate correlated constraints inside one transaction but cannot persist an invalid final state. Fe's explicit access model also rejects a call made while a conflicting mutable storage access is open (`error[16-0001]`); `previewIncidentActions()` and `commitIncidentActions()` independently check supplied incident requirements in actual Fe EVM bytecode.

**What judges can reproduce:** Run `node scripts/reproduce.mjs` with Fe 26.5.0 and Node 20+. It runs 34 Fe tests, the expected compiler rejection, 31 Node/EVM/HTTP tests, and a direct Fe incident adversarial witness. For UI demonstration, run `npm start`, visit localhost port 4549, and choose Incident response.

**Documented proof:** The original v1.8 release passed the entrant's Windows Fe 34/34, Node 31/31 and independent witness checks. The lockfile clean-install release gate passed. `evidence/owner-v17-local-audit.json` is an actual local sandbox export from November 7, 2026: one successful Fe incident-attested transaction, v1 400/300/100 → v2 200/300/100, Core cap 200, reserve 400, Fe incident mask 0, 52,442 local gas. This record has a SHA-256-linked journal and is not a public blockchain receipt.

**Limitation statement:** No oracle, real assets, persistent on-chain incident registration, authenticated multi-user API, or production deployment. Temporary incident conditions are checked when calling the incident-specific Fe entry point but do not restrict other authorized commit methods. Planner candidates are bounded and not globally optimal.

**AI/reuse disclosure:** The entrant drove product decisions and performed real Windows compiler/browser acceptance. ChatGPT assisted extensively with source code, UI, tests, integration, packaging, and documentation. Fe standard libraries, EthereumJS and ethers are dependencies; pre-contest language feasibility experiments informed the design. See `docs/PROVENANCE_AI.md`.

**Public repo URL:** `PENDING_OWNER_PUBLICATION`

**Full judged Git commit:** `PENDING_FULL_SHA`

**Registered contest ID:** `PENDING_OWNER_CONFIRMATION`
