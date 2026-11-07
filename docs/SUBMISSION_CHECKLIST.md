# Fe Builders Challenge — submission readiness checklist

Official rules: https://fe-lang.org/contest/

**Dates (UTC):** build November 3–24, 2026; register by **November 17, 23:59 UTC**; submit by **November 24, 23:59 UTC**. Check official site if these details change.

- [ ] Register via the official registration form; obtain the project ID and **private** submission link by email. Registration is required even if the project is completed.
- [x] The entrant ran the original v1.8 Windows launcher: 34/34 Fe tests, 31/31 Node tests, negative compiler `16-0001`, adversarial Fe incident witness, and local EVM readiness all passed. The portable `node scripts/reproduce.mjs` remains the judge-facing reproduction command; an additional fresh-checkout run is optional.
- [x] Include `package-lock.json` generated in the entrant's connected Windows environment; its SHA-256 is `200C50BDA3F4AFBEA9E86EC22A8769CD0682072E66B58CDE6E0773BC4FE6BB5E`. The Windows release gate passed a clean `npm ci`, direct-tree check, 31/31 Node tests, and the independent Fe witness.
- [ ] Entrant: review the MIT license, provenance/AI disclosure, and security/limitations statements for factual accuracy before publication.
- [ ] Publish project source to a **public GitHub repository**; do **not** commit node_modules, artifacts, mutable runtime JSONL logs, account secrets, or `results/` outputs.
- [ ] After the final Git commit, copy the **full 40-character commit SHA** (do not invent or abbreviate it). Include the actual repository URL and full SHA in the submission.
- [ ] Include the project manifest (`package.json`), exact Fe 26.5.0 version and reproducible build/test commands.
- [ ] Use `docs/JUDGE_START_HERE.md` for the pitch and demo; add an optional short screen recording if useful (not required).
- [ ] Include `docs/PROVENANCE_AI.md` to disclose preparatory work, reused dependencies, and AI assistance.
- [ ] Complete the official personal submission form with the registered ID, repository URL and full SHA. The latest valid submission before the deadline counts.
- [ ] Check confirmation **email** that automated submission checks passed; the form receipt alone does not confirm acceptance.

**Contest technical score weighting:** 30% technical quality, 25% Fe-specific value, 20% originality, 15% usefulness or insight, 10% documentation/demo. A public chain deployment and a video are not mandatory. Prize payouts, if awarded, are USDC on Ethereum Mainnet according to the official contest rules; choose an address you control only when the organizers request one.

## Submission fields to fill (never invent these)

- Public GitHub repository: `PENDING_OWNER_PUBLICATION`
- Full Git commit SHA: `PENDING_FINAL_COMMIT`
- Registration/project ID: `PENDING_REGISTRATION_CONFIRMATION`
- Registered contact email: `PENDING_OWNER_INPUT`
- Optional demo URL/video: `PENDING_IF_PREPARED`
