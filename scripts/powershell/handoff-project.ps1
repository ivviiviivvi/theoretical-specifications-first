#!/usr/bin/env pwsh

# Handoff script for project import/export between SDD and non-SDD formats
#
# This script provides context and path information for the handoff command.
# The actual handoff logic is implemented in the command template.
#
# Usage: ./handoff-project.ps1 [-Json]
#
# PARAMETERS:
#   -Json               Output in JSON format
#
# OUTPUTS:
#   JSON mode: JSON object with repository context
#   Text mode: Human-readable status

param(
    [switch]$Json,
    [switch]$Help
)

if ($Help) {
    Write-Host @"
Usage: handoff-project.ps1 [OPTIONS]

Provide context for project handoff operations (import/export).

OPTIONS:
  -Json               Output in JSON format
  -Help               Show this help message

EXAMPLES:
  # Get handoff context in JSON
  ./handoff-project.ps1 -Json
  
  # Get handoff context in human-readable format
  ./handoff-project.ps1
  
"@
    exit 0
}

# Source common functions
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

# Get repository context
$repoRoot = Get-RepoRoot
$specsDir = Join-Path $repoRoot "specs"
$constitution = Join-Path $repoRoot "memory/constitution.md"
$readme = Join-Path $repoRoot "README.md"
$templatesDir = Join-Path $repoRoot ".specify/templates"

# Check if this is an SDD repository
$isSddRepo = $false
if ((Test-Path (Join-Path $repoRoot ".specify")) -or (Test-Path (Join-Path $repoRoot "memory"))) {
    $isSddRepo = $true
}

# Count existing features
$featureCount = 0
if (Test-Path $specsDir) {
    $featureCount = (Get-ChildItem -Path $specsDir -Directory | Measure-Object).Count
}

# Determine current context
$hasGit = Test-HasGit
$currentBranch = Get-CurrentBranch

# Check constitution status
$constitutionStatus = "missing"
if (Test-Path $constitution) {
    if ((Get-Item $constitution).Length -gt 0) {
        $constitutionStatus = "present"
    } else {
        $constitutionStatus = "empty"
    }
}

# Output results
if ($Json) {
    $result = @{
        REPO_ROOT = $repoRoot
        SPECS_DIR = $specsDir
        CONSTITUTION = $constitution
        CONSTITUTION_STATUS = $constitutionStatus
        README = $readme
        TEMPLATES_DIR = $templatesDir
        IS_SDD_REPO = $isSddRepo
        HAS_GIT = $hasGit
        CURRENT_BRANCH = $currentBranch
        FEATURE_COUNT = $featureCount
    }
    
    $result | ConvertTo-Json -Compress
} else {
    Write-Host "Handoff Context:"
    Write-Host "  Repository Root: $repoRoot"
    Write-Host "  Is SDD Repository: $isSddRepo"
    Write-Host "  Constitution: $constitutionStatus"
    Write-Host "  Feature Count: $featureCount"
    Write-Host "  Git Available: $hasGit"
    if ($hasGit) {
        Write-Host "  Current Branch: $currentBranch"
    }
}
