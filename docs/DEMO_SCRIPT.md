# Optional 90-second product walkthrough

**Do not read developer notes or show private Windows folders.** This walkthrough uses only the prebuilt localhost app and completely synthetic allocations.

0–12s — On the Incident Response screen: “Protocol operators need to respond to changing risk limits without applying an unsafe partial configuration. Covenant Control lets them choose an objective and execute the response atomically.”

12–35s — Choose **Core risk · 200 limit**. Show the three response cards: Keep capacity active, Spread exposure, Build protective reserve. Mention “Fe checks every proposed plan. Their trade-offs are different even though they resolve the same incident.”

35–58s — Select Build protective reserve. Point to the two Fe guarantees: the normal policy verdict and the independent incident mask `0`, with exact target match. Commit once with the authorized local demo signer.

58–75s — Show v1 → v2, `400/300/100 → 200/300/100`, and reserve `200 → 400`. In History, show the local receipt and 52,442 gas from the owner's accepted release (a fresh run can have different gas if the toolchain changes).

75–90s — “Here is the Fe difference: our contract’s scoped edit validates the final state even after multi-step changes; its explicit access model rejects unsafe external calls at compile time; its incident-specific commit rechecks exposure, reserve, and exact target on the EVM. No wallet or real funds are involved.”

**More technical judges:** `node scripts/reproduce.mjs` additionally runs `scripts/demo.mjs`, including a direct call that is valid under ordinary Fe policy but invalid under incident limits and therefore reverts.

Avoid saying this is production-ready, an externally authenticated alert, on-chain permanent emergency freeze, or public-chain audit proof. A video is optional under the challenge rules.
