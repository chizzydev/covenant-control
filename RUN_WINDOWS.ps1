# Covenant Control v1.8 — Windows PowerShell 7 launcher.
# Compile and test real Fe 26.5.0 code before starting an isolated EVM UI.
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$FeExe = Join-Path $HOME 'Downloads\FE_PROGRESSIVE_DECISIVE_GATE\toolchain\fe.exe'
$Source = Join-Path $Root 'contracts\CovenantControl.fe'
$Negative = Join-Path $Root 'contracts\IllegalCall.negative.fe'
$Artifacts = Join-Path $Root 'artifacts'
$ResultsDir = Join-Path $Root 'results'
$Results = Join-Path $ResultsDir 'RUN_LOG.txt'

$ExpectedFe = 'D86CA3C6FDADEB8335F7033E3A68FDB7D2AAB4EAFD22C1E23BEC047D2A8B2674'
$ExpectedSource = '3B98628A9EAD95CF271CEE86C62F0D20E88398314AC6AC62DC1AE717A1B7286D'
$ExpectedNegative = 'F4CEC009D76DCF0ED99EE25FB309F91B2621A0BDCAF2129A299B2C4455C809CD'

New-Item -ItemType Directory -Force -Path $ResultsDir, $Artifacts | Out-Null
Set-Content -LiteralPath $Results -Value '=== COVENANT CONTROL INTEGRATED FE VERTICAL SLICE ===' -Encoding UTF8
function Say([string]$Line) {
    Write-Host $Line
    Add-Content -LiteralPath $Results -Value $Line -Encoding UTF8
}
function RunFe([string]$Stage, [string[]]$FeArguments) {
    Say "STAGE=$Stage"
    $Old = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $Output = @(& $FeExe @FeArguments 2>&1)
        $Code = $LASTEXITCODE
    }
    finally { $ErrorActionPreference = $Old }
    foreach ($Line in $Output) {
        $Value = ($Line | Out-String).TrimEnd()
        if ($Value) { Say $Value }
    }
    Say "${Stage}_EXIT=$Code"
    return @{ Code = $Code; Text = ($Output | Out-String) }
}

Say 'ADMIN_REQUIRED=NO'
Say 'PUBLIC_CHAIN=NO'
Say 'REAL_CREDENTIALS=NO'
Say 'LOCAL_FUNDS_ONLY=YES'
Say 'NETWORK=ONLY_FOR_FIRST_NPM_DEPENDENCY_INSTALL'

foreach ($File in @($FeExe, $Source, $Negative)) {
    if (-not (Test-Path -LiteralPath $File)) { throw "REQUIRED_FILE_MISSING=$File" }
}
$FeHash = (Get-FileHash -LiteralPath $FeExe -Algorithm SHA256).Hash
if ($FeHash -ine $ExpectedFe) { throw 'FE_COMPILER_SHA256_MISMATCH' }
if ((Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash -ine $ExpectedSource) {
    throw 'FE_SOURCE_SHA256_MISMATCH'
}
if ((Get-FileHash -LiteralPath $Negative -Algorithm SHA256).Hash -ine $ExpectedNegative) {
    throw 'NEGATIVE_SOURCE_SHA256_MISMATCH'
}
Say 'COMPILER_AND_SOURCE_SHA256=PASS'

$ManifestPath = Join-Path $Root 'SOURCE_MANIFEST_SHA256.txt'
if (-not (Test-Path -LiteralPath $ManifestPath)) { throw 'SOURCE_MANIFEST_MISSING' }
$ManifestChecked = 0
foreach ($EntryLine in Get-Content -LiteralPath $ManifestPath -Encoding UTF8) {
    if ($EntryLine -match '^([a-fA-F0-9]{64})  ([a-zA-Z0-9_./-]+)$') {
        $ExpectedHash = $Matches[1]
        $Relative = $Matches[2]
    } else { continue }
    if ($Relative.Contains('..')) { throw 'MANIFEST_RELATIVE_PATH_UNSAFE' }
    $FilePath = Join-Path $Root ($Relative.Replace('/', [System.IO.Path]::DirectorySeparatorChar))
    if (-not (Test-Path -LiteralPath $FilePath)) { throw "MANIFEST_FILE_MISSING=$Relative" }
    $ActualHash = (Get-FileHash -LiteralPath $FilePath -Algorithm SHA256).Hash
    if ($ActualHash -ine $ExpectedHash) { throw "MANIFEST_FILE_HASH_MISMATCH=$Relative" }
    $ManifestChecked++
}
if ($ManifestChecked -ne 38) { throw "MANIFEST_EXPECTED_38_FILES_FOUND=$ManifestChecked" }
Say "SOURCE_MANIFEST_FILES_VERIFIED=$ManifestChecked"

$Version = (& $FeExe --version | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $Version -notmatch '26\.5\.0') { throw "FE_VERSION_UNEXPECTED=$Version" }
Say "FE_VERSION=$Version"

# v1.7.1 defensive preflight: all typed Snapshot responses MUST match the
# declared 9-word Fe Snapshot ABI. This would have caught the v1.7 typo
# before the compiler and its integration tests. Match only calls to Snapshot.
$SourceText = Get-Content -LiteralPath $Source -Raw -Encoding UTF8
$SnapshotPattern = 'let\s+[A-Za-z_]\w*\s*:\s*\(([^)]*)\)\s*=\s*evm\.call\((?:(?!message:\s*ControlMsg::)[\s\S]){0,240}?message:\s*ControlMsg::Snapshot\s*\{\s*\}'
$SnapshotBindings = [regex]::Matches($SourceText, $SnapshotPattern)
if ($SnapshotBindings.Count -lt 21) {
    throw "SNAPSHOT_BINDING_PREFLIGHT_INCOMPLETE=$($SnapshotBindings.Count)"
}
foreach ($Binding in $SnapshotBindings) {
    $FieldTypes = @($Binding.Groups[1].Value.Split(',') | ForEach-Object { $_.Trim() })
    if ($FieldTypes.Count -ne 9 -or @($FieldTypes | Where-Object { $_ -cne 'u256' }).Count -ne 0) {
        throw "SNAPSHOT_BINDING_TUPLE_MISMATCH_EXPECTED_9_U256_FOUND=$($Binding.Groups[1].Value)"
    }
}
Say "FE_SNAPSHOT_TUPLE_ARITY=$($SnapshotBindings.Count)_BINDINGS_MATCH_9_FIELDS"

$Tests = RunFe 'FE_UNIT_AND_EVM_TEST' @('test', '--jobs', '1', $Source)
if ($Tests.Code -ne 0) { throw "FE_TEST_FAILED=$($Tests.Code)" }
if ($Tests.Text -notmatch 'test result:\s*ok\.\s*34 passed;\s*0 failed') {
    throw 'FE_EXPECTED_34_TESTS_NOT_CONFIRMED'
}
Say 'FE_RUNTIME_TESTS=34_PASS_0_FAIL'

$Build = RunFe 'FE_COMPILE_AND_ABI' @('build', '--out-dir', $Artifacts, $Source)
if ($Build.Code -ne 0) { throw "FE_BUILD_FAILED=$($Build.Code)" }
foreach ($Name in @('CovenantControl.bin', 'CovenantControl.runtime.bin', 'CovenantControl.abi.json')) {
    if (-not (Test-Path -LiteralPath (Join-Path $Artifacts $Name))) {
        throw "FE_REQUIRED_ARTIFACT_MISSING=$Name"
    }
}
Say 'FE_BYTECODE_AND_ABI=PASS'

$NegativeResult = RunFe 'COMPILER_ACCESS_RESTRICTION' @('check', $Negative)
if ($NegativeResult.Code -eq 0) { throw 'UNSAFE_CONTRACT_COMPILED_UNEXPECTEDLY' }
if ($NegativeResult.Text -notmatch 'error\[16-0001\]') {
    throw 'EXPECTED_ACCESS_CONFLICT_DIAGNOSTIC_NOT_FOUND'
}
Say 'COMPILER_ACCESS_CONFLICT_16-0001=PASS'

$Node = Get-Command node.exe -ErrorAction Stop
$Npm = Get-Command npm.cmd -ErrorAction Stop
$NodeVersion = (& $Node.Source --version | Out-String).Trim()
$Major = [int]($NodeVersion -replace '^v(\d+).*$', '$1')
if ($Major -lt 20) { throw "NODE_20_REQUIRED_FOUND=$NodeVersion" }
Say "NODE_VERSION=$NodeVersion"
Say 'STAGE=SUBMISSION_REPRODUCTION_PREFLIGHT'
& $Node.Source (Join-Path $Root 'scripts\reproduce.mjs') --check
if ($LASTEXITCODE -ne 0) { throw 'RELEASE_REPRODUCTION_PREFLIGHT_FAILED' }
Say 'SUBMISSION_REPRODUCTION_PREFLIGHT=PASS'

Push-Location $Root
try {
    # A failed npm install can leave node_modules partly populated. Verify the
    # complete top-level tree rather than just looking for one directory.
    $NeedInstall = $true
    if (Test-Path -LiteralPath (Join-Path $Root 'node_modules\@ethereumjs\vm')) {
        & $Npm.Source ls --depth=0 --omit=dev *> $null
        if ($LASTEXITCODE -eq 0) { $NeedInstall = $false }
    }
    if ($NeedInstall) {
        Say 'STAGE=NPM_DEPENDENCY_INSTALL'
        Say 'NETWORK_REQUIRED_FOR_THIS_STAGE=YES'
        & $Npm.Source install --no-audit --no-fund
        if ($LASTEXITCODE -ne 0) { throw "NPM_INSTALL_FAILED=$LASTEXITCODE" }
        Say 'NPM_DEPENDENCIES=INSTALLED'
    }
    else { Say 'NPM_DEPENDENCIES=ALREADY_VERIFIED' }
    & $Npm.Source ls --depth=0 --omit=dev
    if ($LASTEXITCODE -ne 0) { throw 'NPM_DEPENDENCY_TREE_INVALID' }
    Say 'NPM_PINNED_TREE=PASS'

    Say 'STAGE=NODE_SYNTAX_CHECK'
    & $Npm.Source run check:js
    if ($LASTEXITCODE -ne 0) { throw "JS_SYNTAX_FAILED=$LASTEXITCODE" }

    Say 'STAGE=REAL_FE_EVM_HTTP_AND_AUDIT_TESTS'
    & $Npm.Source run smoke
    if ($LASTEXITCODE -ne 0) { throw "RUNTIME_SMOKE_FAILED=$LASTEXITCODE" }
    Say 'CROSS_LAYER_FE_EVM_INCIDENT_ATTESTATION_AND_AUDIT_SMOKE=PASS'

    Say 'STAGE=INDEPENDENT_FE_INCIDENT_WITNESS'
    & $Node.Source (Join-Path $Root 'scripts\demo.mjs')
    if ($LASTEXITCODE -ne 0) { throw 'INDEPENDENT_FE_INCIDENT_WITNESS_FAILED' }
    Say 'INDEPENDENT_FE_INCIDENT_WITNESS=PASS'
    $PortClient = [System.Net.Sockets.TcpClient]::new()
    try {
        $Async = $PortClient.BeginConnect('127.0.0.1', 4549, $null, $null)
        if ($Async.AsyncWaitHandle.WaitOne(200) -and $PortClient.Connected) {
            throw 'PORT_4549_IN_USE_STOP_PREVIOUS_COVENANT_SERVER_WITH_CTRL_C'
        }
    }
    finally { $PortClient.Dispose() }

    Say 'STAGE=START_LOCAL_WORKSPACE'
    Say 'OPEN_BROWSER=http://127.0.0.1:4549'
    Say 'KEEP_THIS_WINDOW_OPEN=YES'
    Say 'PRESS_CTRL_C_TO_STOP=YES'
    Say 'AUDIT_JOURNAL_PERSISTS_ACROSS_RESTARTS=YES'
    Say 'EVM_STATE_RESETS_ON_RESTART=YES'
    & $Node.Source (Join-Path $Root 'app\server.mjs')
    $ServerExit = $LASTEXITCODE
    Say "SERVER_EXIT=$ServerExit"
    if ($ServerExit -ne 0) { throw "SERVER_EXIT_NONZERO=$ServerExit" }
}
finally {
    Pop-Location
}
