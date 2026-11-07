# v1.5.1 — Local acceptance record

Source: operator-exported `covenant-control-local-audit.json`, submitted November 7, 2026.

Source file SHA-256: `045a6d32610e75160c48316cb8ac965b2488a8d2f7e196544b31c474b40c327e`

- Local EVM session: `0c563e13-5e0f-4dd6-a35f-f3237dc7f3c1`
- 3 journal entries: one session start and **two successful goal-attested transactions**.
- Transaction at 2026-11-07T13:28:24Z: move **150** Core → Supporting; v1 (`400/300/100`) to v2 (`250/450/100`), 54,806 local gas, Fe policy mask 0, operation error 0.
- Transaction at 2026-11-07T13:33:25Z: move **50** Core → Supporting; v2 (`250/450/100`) to v3 (`200/500/100`), 54,806 local gas, Fe policy mask 0, operation error 0.
- Final journal digest in export: `e8123a0a5407daec2c19d61680dec6527bba6c08f5495a62ee873bb6ea7cdb38`.

The export includes local transaction hashes, a role selector for disposable simulation accounts, and source-level plan fingerprints. It is **not an attestation from a public Ethereum network**, does not prove tamper resistance, and does not establish any real-asset movement. The original JSON is intentionally not included in this project distribution.
