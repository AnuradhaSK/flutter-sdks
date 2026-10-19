<#
.SYNOPSIS
    Fetch the Flutter Quickstart sample and point it at this SDK checkout.

.DESCRIPTION
    Windows equivalent of prepare-sample.sh. Fetches the sample from the samples repository and
    writes a pubspec_overrides.yaml so the E2E suite exercises the local plugin rather than the
    release published on pub.dev. Returns the prepared sample directory.

.NOTES
    Environment variables, all optional:
      THUNDERID_SAMPLES_DIR   An existing local checkout of the samples repository to copy the
                              sample from, never modified (default: fetch one into tests\e2e\.samples)
      THUNDERID_SAMPLES_REPO  Repository to fetch (default https://github.com/thunder-id/samples.git)
      THUNDERID_SAMPLES_REF   Branch, tag or commit to fetch (default main)
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$E2eDir   = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$RepoRoot = (Resolve-Path (Join-Path $E2eDir '../..')).Path

function Get-EnvOrDefault([string]$Name, [string]$Default) {
    $value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
    return $value
}

function Invoke-Git {
    & git @args | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "git $($args -join ' ') failed with exit code $LASTEXITCODE." }
}

$SamplesRepo = Get-EnvOrDefault 'THUNDERID_SAMPLES_REPO' 'https://github.com/thunder-id/samples.git'
$SamplesRef  = Get-EnvOrDefault 'THUNDERID_SAMPLES_REF' 'main'
$SamplesDir  = Get-EnvOrDefault 'THUNDERID_SAMPLES_DIR' ''

if ($SamplesDir) {
    $SourceDir = Join-Path (Resolve-Path $SamplesDir).Path 'quickstarts/flutter'
    if (-not (Test-Path $SourceDir)) {
        throw "No Flutter Quickstart sample at $SourceDir."
    }
    $SamplesDir = Join-Path $E2eDir '.samples'
    Write-Host "==> Copying the sample from $SourceDir"
    if (Test-Path $SamplesDir) { Remove-Item -Recurse -Force $SamplesDir }
    $Target = Join-Path $SamplesDir 'quickstarts/flutter'
    New-Item -ItemType Directory -Force -Path $Target | Out-Null
    Get-ChildItem -Force $SourceDir |
        Where-Object { $_.Name -notin @('build', '.dart_tool', 'pubspec_overrides.yaml') } |
        Copy-Item -Destination $Target -Recurse -Force
} else {
    $SamplesDir = Join-Path $E2eDir '.samples'
    Write-Host "==> Fetching $SamplesRepo@$SamplesRef into $SamplesDir"
    # init + fetch rather than clone, so a re-run updates the existing checkout in place and the
    # ref can be a commit as well as a branch or tag.
    Invoke-Git init -q $SamplesDir
    Invoke-Git -C $SamplesDir fetch -q --depth 1 $SamplesRepo $SamplesRef
    Invoke-Git -C $SamplesDir checkout -q --force FETCH_HEAD
    # Drop anything a previous run left behind (build output, a copied sample).
    Invoke-Git -C $SamplesDir clean -q -f -d -x
}

$SampleDir = Join-Path $SamplesDir 'quickstarts/flutter'
if (-not (Test-Path (Join-Path $SampleDir 'pubspec.yaml'))) {
    throw "No Flutter Quickstart sample at $SampleDir."
}

Write-Host "==> Pointing the sample at the local SDK in $RepoRoot"
# pubspec_overrides.yaml takes precedence over the sample's pub.dev constraint without editing
# its pubspec.yaml. Forward slashes keep the YAML free of backslash escapes.
@(
    'dependency_overrides:'
    '  thunderid_flutter:'
    "    path: $($RepoRoot -replace '\\', '/')"
) | Set-Content -Path (Join-Path $SampleDir 'pubspec_overrides.yaml') -Encoding utf8

return $SampleDir
