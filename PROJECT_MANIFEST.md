# Covenant Control — versioned project manifest

- **Product:** Covenant Control (Fe Builders Challenge 2026)
- **Application version:** 0.1.8 (release hardening); Fe contract logic identical to v1.7.1
- **Language/compiler:** Fe 26.5.0 (`fe 26.5.0 (3dab95f)` on the owner's Windows machine)
- **Known owner's Fe executable SHA-256:** `d86ca3c6fdadeb8335f7033e3a68fdb7d2aab4eafd22c1e23bec047d2a8b2674`
- **Fe source:** `contracts/CovenantControl.fe`, SHA-256 `3b98628a9ead95cf271cee86c62f0d20e88398314ac6ac62dc1ae717a1b7286d`
- **Fe negative compiler fixture:** `contracts/IllegalCall.negative.fe`, compiler diagnostic `16-0001`
- **Contract interfaces:** ABI produced by `fe build --out-dir artifacts contracts/CovenantControl.fe`
- **Node runtime:** 20+; owner ran Node v24.13.0
- **Direct packages:** `@ethereumjs/common`, `@ethereumjs/tx`, `@ethereumjs/util`, `@ethereumjs/vm` at 10.1.3; `ethers` at 6.16.0; see exact `package.json`
- **HTTP:** localhost `127.0.0.1:4549` only; no external RPC or funded account
- **Tests:** 34 Fe tests; 31 integrated Node/EVM/HTTP/audit/planner/incident tests; compiler rejection fixture; independent local incident witness
- **Command:** `node scripts/reproduce.mjs` (Fe on PATH or `FE_EXE`); then `npm start`
- **Static check:** `node scripts/reproduce.mjs --check`
- **License:** MIT
- **Runtime outputs:** `artifacts/` and `results/` are generated and ignored by Git
- **Dependency lock:** `package-lock.json` included; SHA-256 `200c50bda3f4afbea9e86ec22a8769cd0682072e66b58cde6e0773bc4fe6bb5e`, clean Windows `npm ci` release gate passed
- **Public repository:** publication pending; this source tree is prepared for initial commit
- **Final Git commit SHA:** pending actual public Git commit; obtain using `git rev-parse HEAD` only after publication

The original **38 release source files** (excluding `SOURCE_MANIFEST_SHA256.txt`) are covered by that SHA-256 manifest. The subsequently added `package-lock.json` and `evidence/owner-v18-independent-judge-witness.json` have their own digests in `PUBLICATION_ADDITIONS_SHA256.txt`. These checks prove package consistency, not authorship or independent provenance.
