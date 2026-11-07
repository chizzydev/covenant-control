#!/usr/bin/env node
// Portable Fe Builders Challenge reproduction helper (Node 20+).
// --check: no external dependencies or Fe executable; static release check.
// default: Fe tests -> bytecode -> compiler rejection -> npm deps -> Node
// tests -> independent local EVM witness. Network is needed only for npm
// dependencies when not already installed.
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const checkOnly = process.argv.includes('--check');
const nodeBin = process.execPath;
const isWin = process.platform === 'win32';
const npmBin = isWin ? 'npm.cmd' : 'npm';
const must = (x, msg) => { if (!x) throw new Error(msg); };
const file = relative => resolve(root,relative);
const digest = path => createHash('sha256').update(readFileSync(path)).digest('hex').toUpperCase();
const minimumMajor = 20;

function run(stage, binary, args, {expect=0,shell=false,timeout=180000}={}) {
  console.log(`STAGE=${stage}`);
  const p=spawnSync(binary,args,{cwd:root,encoding:'utf8',maxBuffer:16*1024*1024,
    timeout,shell,env:process.env});
  if(p.stdout) process.stdout.write(p.stdout);
  if(p.stderr) process.stderr.write(p.stderr);
  must(!p.error,`${stage}: ${p.error?.message}`);
  if(expect==='nonzero') must(p.status !== 0 && p.status !== null,`${stage}: expected compiler rejection`);
  else must(p.status===expect,`${stage}: unexpected exit code ${p.status}`);
  return (p.stdout||'')+'\n'+(p.stderr||'');
}

function staticPreflight() {
  const major=Number(process.versions.node.split('.')[0]);
  must(major>=minimumMajor,`Node >=${minimumMajor} required, found ${process.version}`);
  const manifest=file('SOURCE_MANIFEST_SHA256.txt');
  must(existsSync(manifest),'SOURCE_MANIFEST_MISSING');
  let verified=0;
  const all=readFileSync(manifest,'utf8').split(/\r?\n/);
  for(const line of all) {
    if(!line.trim()) continue;
    const m=/^([a-fA-F0-9]{64})  ([A-Za-z0-9_.\/-]+)$/.exec(line);
    must(m,`SOURCE_MANIFEST_INVALID_LINE: ${line}`);
    const relative=m[2];
    must(!relative.split('/').includes('..')&&!relative.startsWith('/'),`SOURCE_MANIFEST_PATH_UNSAFE ${relative}`);
    const target=file(relative);
    must(target.startsWith(root+sep),`SOURCE_MANIFEST_ESCAPE ${relative}`);
    must(existsSync(target),`SOURCE_MANIFEST_MISSING ${relative}`);
    must(digest(target)===m[1].toUpperCase(),`SOURCE_MANIFEST_HASH_MISMATCH ${relative}`);
    verified++;
  }
  must(verified===38,`SOURCE_MANIFEST_FILE_COUNT_UNEXPECTED ${verified} (expected 38)`);
  console.log(`SOURCE_MANIFEST_FILES_VERIFIED=${verified}`);
  must(existsSync(file('LICENSE'))&&existsSync(file('README.md'))&&existsSync(file('docs/JUDGE_START_HERE.md')),'SUBMISSION_HANDOFF_INCOMPLETE');
  const src=readFileSync(file('contracts/CovenantControl.fe'),'utf8');
  const pattern=/let\s+\w+\s*:\s*\(([^)]*)\)\s*=\s*evm\.call\((?:(?!message:\s*ControlMsg::)[\s\S]){0,240}?message:\s*ControlMsg::Snapshot\s*\{\s*\}/g;
  const matches=[...src.matchAll(pattern)];
  must(matches.length>=21,`SNAPSHOT_PREFLIGHT_INCOMPLETE ${matches.length}`);
  for(const m of matches) must(m[1].split(',').map(x=>x.trim()).join(',')===Array(9).fill('u256').join(','),'SNAPSHOT_TUPLE_ARITY_MISMATCH');
  console.log(`FE_SNAPSHOT_TUPLE_ARITY=${matches.length}_BINDINGS_MATCH_9_FIELDS`);
  const feTests=(src.match(/#\[test\]/g)||[]).length;
  must(feTests===34,`FE_TEST_SOURCE_COUNT_MISMATCH ${feTests}`);
  console.log('FE_TEST_SOURCE_COUNT=34');
  const p=JSON.parse(readFileSync(file('package.json'),'utf8'));
  for (const [name,v] of Object.entries(p.dependencies)) {
    must(!/[\^~*><=]/.test(v),`UNPINNED_DIRECT_DEPENDENCY ${name}`);
  }
  console.log('NPM_DIRECT_DEPENDENCIES=EXACT_PINNED');
  const lock=existsSync(file('package-lock.json'));
  if(!lock) console.log('WARNING=NPM_LOCKFILE_NOT_INCLUDED_FRESH_NPM_INSTALL_CAN_RESOLVE_NEW_TRANSITIVES');
  run('JS_SYNTAX_STATIC',nodeBin,['--check',file('scripts/demo.mjs')]);
  run('AUDIT_EVIDENCE_VERIFICATION',nodeBin,[file('scripts/verify-evidence.mjs'),file('evidence/owner-v17-local-audit.json')]);
  console.log('SOURCE_AND_EVIDENCE_PREFLIGHT=PASS');
  return lock;
}
function feExecutable() {
  if(process.env.FE_EXE) return process.env.FE_EXE;
  if(isWin){
    const home=process.env.USERPROFILE||process.env.HOME||'';
    const local=resolve(home,'Downloads','FE_PROGRESSIVE_DECISIVE_GATE','toolchain','fe.exe');
    if(existsSync(local)) return local;
  }
  return 'fe';
}
function main() {
  const locked=staticPreflight();
  if(checkOnly){console.log('STATIC_RELEASE_CHECK=PASS');return;}
  const fe=feExecutable();
  const version=run('FE_VERSION',fe,['--version'],{timeout:30000});
  must(/\bfe\s+26\.5\.0\b/.test(version),'FE_COMPILER_VERSION_NOT_26_5_0');
  console.log(`FE_COMPILER_BINARY=${fe}`);
  if(existsSync(fe)) console.log(`FE_COMPILER_SHA256=${digest(fe)}`);
  const source=file('contracts/CovenantControl.fe');
  const neg=file('contracts/IllegalCall.negative.fe');
  const tests=run('FE_34_TESTS',fe,['test','--jobs','1',source],{timeout:180000});
  must(/test result:\s*ok\.\s*34 passed;\s*0 failed/.test(tests),'FE_TEST_COUNT_NOT_VERIFIED');
  mkdirSync(file('artifacts'),{recursive:true});
  run('FE_BUILD',fe,['build','--out-dir',file('artifacts'),source]);
  for(const name of ['CovenantControl.bin','CovenantControl.runtime.bin','CovenantControl.abi.json'])
    must(existsSync(file(`artifacts/${name}`)),`FE_ARTIFACT_MISSING ${name}`);
  const illegal=run('FE_COMPILER_ACCESS_CONFLICT',fe,['check',neg],{expect:'nonzero'});
  must(/error\[16-0001\]/.test(illegal),'ACCESS_CONFLICT_DIAGNOSTIC_MISSING');
  const tree=spawnSync(npmBin,['ls','--depth=0','--omit=dev'],{cwd:root,encoding:'utf8',shell:isWin});
  if(tree.status!==0) {
    run('NPM_INSTALL',npmBin,[locked?'ci':'install','--no-audit','--no-fund'],{shell:isWin,timeout:240000});
  }
  run('NODE_SYNTAX',npmBin,['run','check:js'],{shell:isWin});
  const nodeTests=run('NODE_EVM_HTTP_SUITE',npmBin,['run','smoke'],{shell:isWin,timeout:240000});
  must(/(?:^|\n)\s*(?:[ℹ#]\s*)?tests\s+31\s*(?:\n|$)/.test(nodeTests)&&
    /(?:^|\n)\s*(?:[ℹ#]\s*)?pass\s+31\s*(?:\n|$)/.test(nodeTests)&&
    /(?:^|\n)\s*(?:[ℹ#]\s*)?fail\s+0\s*(?:\n|$)/.test(nodeTests),'NODE_TEST_31_31_NOT_VERIFIED');
  run('FE_INCIDENT_INDEPENDENT_WITNESS',nodeBin,[file('scripts/demo.mjs')],{timeout:120000});
  console.log('REPRODUCTION=PASS');
  console.log(`REPRODUCIBILITY_DEPENDENCY_LOCK=${locked?'COMMITTED':'GENERATED_LOCALLY_NOT_INCLUDED_IN_RELEASE'}`);
  console.log('NEXT=npm start   (then visit http://127.0.0.1:4549)');
}
try {main();} catch(e){console.error('REPRODUCTION=FAIL',e.message);process.exitCode=1;}
