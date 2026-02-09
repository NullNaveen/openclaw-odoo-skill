# Odoo ERP Connector for OpenClaw — Automated Setup
# 
# This script automates the one-command installation:
# 1. Checks Python 3.10+
# 2. Prompts for Odoo connection details
# 3. Installs Python dependencies
# 4. Generates config.json
# 5. Tests the connection
# 6. Reports success/failure
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File setup.ps1

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

Write-Host "╔════════════════════════════════════════════════════════════════╗"
Write-Host "║         Odoo ERP Connector for OpenClaw — Setup                ║"
Write-Host "╚════════════════════════════════════════════════════════════════╝"
Write-Host ""

# ── Step 1: Check Python ─────────────────────────────────────────────────────
Write-Host "📋 Step 1: Checking Python version..."
$pythonExists = $false
$pythonVersion = $null

try {
    $pythonVersion = python --version 2>&1
    $pythonExists = $?
}
catch {
    $pythonExists = $false
}

if (-not $pythonExists) {
    Write-Host "❌ ERROR: Python is not installed or not in PATH"
    Write-Host ""
    Write-Host "Please install Python 3.10+ from https://www.python.org/"
    Write-Host "Make sure to check 'Add Python to PATH' during installation"
    exit 1
}

Write-Host "✅ Found: $pythonVersion"

# Check version is 3.10+
if ($pythonVersion -match "3\.(1[0-9]|[2-9]\d)") {
    Write-Host "✅ Python version is 3.10 or newer"
}
else {
    Write-Host "⚠️  WARNING: Python version may be older than 3.10"
    Write-Host "   (This may cause compatibility issues)"
}

Write-Host ""

# ── Step 2: Prompt for Odoo Details ──────────────────────────────────────────
Write-Host "📋 Step 2: Odoo Connection Details"
Write-Host ""

$odooUrl = Read-Host "Enter Odoo URL (e.g., http://localhost:8069)"
if ([string]::IsNullOrWhiteSpace($odooUrl)) {
    $odooUrl = "http://localhost:8069"
    Write-Host "   (using default: $odooUrl)"
}

$odooDb = Read-Host "Enter database name (e.g., production)"
if ([string]::IsNullOrWhiteSpace($odooDb)) {
    Write-Host "❌ ERROR: Database name is required"
    exit 1
}

$odooUser = Read-Host "Enter Odoo username/email (e.g., api_user@company.com)"
if ([string]::IsNullOrWhiteSpace($odooUser)) {
    Write-Host "❌ ERROR: Username is required"
    exit 1
}

Write-Host ""
Write-Host "How to get your API Key:"
Write-Host "  1. Log into your Odoo instance"
Write-Host "  2. Click your profile (top-right)"
Write-Host "  3. Go to Settings"
Write-Host "  4. Scroll to 'Access Tokens'"
Write-Host "  5. Click 'Generate Token'"
Write-Host "  6. Copy the token below"
Write-Host ""

$odooApiKey = Read-Host "Enter API Key (from user preferences)"
if ([string]::IsNullOrWhiteSpace($odooApiKey)) {
    Write-Host "❌ ERROR: API Key is required"
    exit 1
}

Write-Host ""

# ── Step 3: Install Dependencies ─────────────────────────────────────────────
Write-Host "📋 Step 3: Installing Python dependencies..."
Write-Host ""

$requirementsFile = "requirements.txt"
if (-not (Test-Path $requirementsFile)) {
    Write-Host "❌ ERROR: $requirementsFile not found"
    Write-Host "   Make sure you're in the OdooConnector directory"
    exit 1
}

try {
    Write-Host "   Running: pip install -r requirements.txt"
    python -m pip install -q -r $requirementsFile
    Write-Host "✅ Dependencies installed"
}
catch {
    Write-Host "❌ ERROR: Failed to install dependencies"
    Write-Host "   $_"
    exit 1
}

Write-Host ""

# ── Step 4: Generate config.json ─────────────────────────────────────────────
Write-Host "📋 Step 4: Creating config.json..."
Write-Host ""

$configContent = @{
    url = $odooUrl
    db = $odooDb
    username = $odooUser
    api_key = $odooApiKey
    timeout = 60
    max_retries = 3
    poll_interval = 60
    log_level = "INFO"
    webhook_port = 8070
    webhook_secret = ""
}

$configJson = $configContent | ConvertTo-Json -Indent 2

try {
    $configJson | Out-File -FilePath "config.json" -Encoding UTF8 -Force
    Write-Host "✅ Created config.json"
}
catch {
    Write-Host "❌ ERROR: Failed to create config.json"
    Write-Host "   $_"
    exit 1
}

Write-Host ""

# ── Step 5: Test Connection ──────────────────────────────────────────────────
Write-Host "📋 Step 5: Testing Odoo connection..."
Write-Host ""

$testScript = @'
import json
import sys
from odoo_skill import OdooClient

try:
    client = OdooClient.from_config("config.json")
    result = client.test_connection()
    print(json.dumps(result))
    sys.exit(0)
except Exception as e:
    print(json.dumps({"error": str(e)}))
    sys.exit(1)
'@

$testOutput = python -c $testScript 2>&1

try {
    $testResult = $testOutput | ConvertFrom-Json
    
    if ($testResult.error) {
        Write-Host "❌ Connection Test FAILED"
        Write-Host ""
        Write-Host "Error: $($testResult.error)"
        Write-Host ""
        Write-Host "Troubleshooting:"
        Write-Host "  • Check Odoo URL is correct and server is running"
        Write-Host "  • Verify database name matches exactly"
        Write-Host "  • Regenerate API key in Odoo user preferences"
        Write-Host "  • Check username is the user email"
        Write-Host ""
        exit 1
    }
    
    Write-Host "✅ Connection successful!"
    Write-Host "   Server: Odoo $($testResult.server_version)"
    Write-Host "   User: $($testResult.user)"
    Write-Host "   Database: $($testResult.db // 'unknown')"
}
catch {
    Write-Host "⚠️  Warning: Could not verify connection automatically"
    Write-Host "   Error: $_"
    Write-Host ""
    Write-Host "   You can test manually with:"
    Write-Host "   python -c `"from odoo_skill import OdooClient; c = OdooClient(); print(c.test_connection())`""
}

Write-Host ""

# ── Success Message ──────────────────────────────────────────────────────────
Write-Host "╔════════════════════════════════════════════════════════════════╗"
Write-Host "║                  ✅ Setup Complete!                            ║"
Write-Host "╚════════════════════════════════════════════════════════════════╝"
Write-Host ""

Write-Host "Next Steps:"
Write-Host ""
Write-Host "1. Configure OpenClaw to use the Odoo skill:"
Write-Host "   In your OpenClaw config file, add:"
Write-Host ""
Write-Host "   skills:"
Write-Host "     - name: odoo"
Write-Host "       type: python"
Write-Host "       path: ./odoo_skill"
Write-Host ""
Write-Host "2. Start OpenClaw and try a command:"
Write-Host ""
Write-Host "   'Create a quotation for Acme Corp with 10 Widgets'"
Write-Host ""
Write-Host "3. See README.md for complete usage guide"
Write-Host ""
Write-Host "Configuration saved to: config.json"
Write-Host "Documentation: README.md and SKILL.md"
Write-Host ""
Write-Host "Happy automating! 🚀"
