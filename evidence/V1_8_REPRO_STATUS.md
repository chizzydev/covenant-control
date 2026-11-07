# v1.8 release verification and handoff status

## Accepted Windows results — November 7, 2026

The entrant reported and provided terminal output for the **original, byte-for-byte verified v1.8 archive**. The archive SHA-256 is `4E0B97057E93D62AE3DCA8442BDFE31098CB7C38476E3B707A0F2B406DCFCC01`. This is owner-observed evidence; it is not an independent third-party security audit.

- Compiler: `fe 26.5.0 (3dab95f)`. Original Fe source SHA-256: `3b98628a9ead95cf271cee86c62f0d20e88398314ac6ac62dc1ae717a1b7286d`.
- Original v1.8 manifest: **38/38 source files verified**. Fe compiler and source SHA-256 preflight passed.
- **34/34 Fe tests passed**, bytecode and ABI generated, and the intentional access-conflict fixture failed compilation with `error[16-0001]` as expected.
- **31/31 Node/EVM/HTTP/audit tests passed**.
- `scripts/demo.mjs` performed its independent-in-process local EVM incident witness: ordinary policy passed for a candidate that the Fe incident limit rejected; excessive reserve and incorrect exact target were rejected; unauthorized and stale operations were rejected; and the accepted incident action committed `v1 400/300/100 → v2 200/300/100` with **52,442 local gas**. The reproduced output is preserved as `evidence/owner-v18-independent-judge-witness.json`.
- `SOURCE_AND_EVIDENCE_PREFLIGHT=PASS` and `COVENANT_LOCAL_EVM=READY` appeared in the entrant's Windows output.
- Subsequent clean-install gate verified `npm ci`, locked direct dependency tree, JavaScript syntax, **31/31** integrated tests, and the independent Fe witness: `COVENANT_V1_8_RELEASE_GATE=PASS`.
- Owner-generated `package-lock.json` SHA-256: `200C50BDA3F4AFBEA9E86EC22A8769CD0682072E66B58CDE6E0773BC4FE6BB5E`.
- The final publication intake matched the original v1.8 source archive and lockfile; the user-provided combined intake SHA-256 was `700C145F4C5F10FB00CA6A43B6F1C9EF32E3D284CDC849B6159287A85CA021E7`.

**Important boundaries:** These transaction hashes belong to an in-memory local EVM, not Ethereum Mainnet or a public explorer. The user supplied a witness JSON and command output; the JSON is self-reported local evidence, not a cryptographic audit attestation. The operator supplies incident limits, and the contract also exposes generic authorized commit methods not restricted by a permanent incident lock. See `docs/SECURITY_LIMITATIONS.md`.

## Historical packaging status (superseded by the Windows results above)

The first v1.8 archive was assembled in an environment without npm registry access or a usable local Fe compiler, so the packaging environment could verify only source hashes, static JavaScript syntax, the Snapshot ABI preflight, audit evidence integrity and audit tamper rejection. **The entrant subsequently completed the Fe/EVM run and produced the lockfile with a clean `npm ci`**; the prior pending status no longer applies to the public repository.

The original production Fe contract and all application code and tests remain byte-for-byte unchanged by the GitHub publication preparation. The updated README and evidence/status documents are release clarification, not new functionality.
