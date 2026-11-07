# Architecture and responsibilities

```
Operator-supplied risk alert (Core <= 200, reserve >= 200)
                 |
                 v
Incident planner (Node, bounded set of candidate strategies)
                 |
     Fe previewActions() + previewIncidentActions() -- local EVM static calls
                 |
        Candidate comparison and operator choice
                 |
         Server recomputes chosen plan and digest
                 |
       Fe commitIncidentActions() -- signed local EVM transaction
                 |
      Ordered operation checks; exact final target;
      incident exposure/reserve checks; scoped final policy
                 |
       v1 -> v2 or whole-transaction rollback
                 |
         Local append-only hash-linked audit JSONL
```

The Fe policy is the executable source of truth. Node constructs candidate objectives and compares outcomes, but does not get final authority to approve an operation or incident commitment. The frontend does not duplicate the Fe policy evaluator.

## Two independent safety types

**Per-operation preconditions** are never waived. `apply_action` rejects transferring more than source inventory, issuing more than presently free capacity, assigning unsupported opcodes, or failing state expectations. The check is order-sensitive.

**End-of-scope invariants** are checked when a mutable Fe projection exits, with `yield mut candidate` and a final `assert!`. Intermediate correlated-policy violations are permitted only inside a single atomic transaction. The final state must pass all permanent constraints.

**Incident-specific attestation** adds checks for the affected market's exposure ceiling, requested unallocated reserve, and exact supplied terminal allocations. A valid permanent-policy state may still be incident-invalid.

## Commitment boundary

The server holds two known artificial demo keys (`0x11...11` and `0x22...22`). The reviewer role is denied by Fe's stored operator authorization. Local request fingerprinting is *not* a signature, external authentication, or persistent policy. A successful Fe commit increments the configuration version exactly once and leaves the final policy healthy. Any revert must leave version and allocations unchanged.

## Reproducibility

`node scripts/reproduce.mjs --check` checks source digests and the owner audit export without npm/Fe. `node scripts/reproduce.mjs` additionally checks actual Fe compiler execution, source-level access-conflict rejection, EVM bytecode, Node/HTTP behavior, and a real local EVM adversarial witness. It never requires a public RPC or real wallet.

The full Windows `RUN_WINDOWS.ps1` uses the original owner-pinned Fe executable (with known SHA-256). The portable reproduction route accepts a valid Fe 26.5.0 from `PATH` or `FE_EXE`.
