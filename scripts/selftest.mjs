#!/usr/bin/env node
// Offline adversarial check: the independent audit verifier must reject
// corruption of an existing transaction while accepting the original.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const original=resolve(root,'evidence/owner-v17-local-audit.json');
const validator=resolve(root,'scripts/verify-evidence.mjs');
const valid=spawnSync(process.execPath,[validator,original],{encoding:'utf8'});
assert.equal(valid.status,0,`Original evidence did not verify: ${valid.stderr}`);
const work=mkdtempSync(join(tmpdir(),'covenant-evidence-tamper-'));
try {
  const json=JSON.parse(readFileSync(original,'utf8'));
  json.journalEntries[1].event.after.a='199';
  const tampered=join(work,'tampered.json');
  writeFileSync(tampered,JSON.stringify(json));
  const altered=spawnSync(process.execPath,[validator,tampered],{encoding:'utf8'});
  assert.notEqual(altered.status,0,'Tampered transaction should not verify');
  assert.match(altered.stderr,/digest mismatch/i,'Incorrect corruption failure reason');
  console.log('ORIGINAL_AUDIT_HASH_CHECK=PASS');
  console.log('TAMPERED_AUDIT_REJECTED=PASS');
} finally {rmSync(work,{recursive:true,force:true});}
