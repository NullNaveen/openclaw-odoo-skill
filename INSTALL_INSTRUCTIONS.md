# Odoo ERP Skill for OpenClaw - Team Distribution

## Installation for Team Members

### Quick Install (Automated)

**For Windows (PowerShell):**
```powershell
# 1. Download this entire 'odoo' folder to your computer

# 2. Run the installer (from inside the odoo folder)
.\install-skill.ps1

# Done! The skill will be installed to your OpenClaw skills directory
```

**For Mac/Linux (Bash):**
```bash
# 1. Download this entire 'odoo' folder to your computer

# 2. Run the installer (from inside the odoo folder)
chmod +x install-skill.sh
./install-skill.sh

# Done! The skill will be installed to your OpenClaw skills directory
```

---

### Manual Install

If the automated installer doesn't work:

**1. Copy the skill folder:**

```powershell
# Windows
Copy-Item -Path ".\odoo" -Destination "$env:APPDATA\npm\node_modules\openclaw\skills\" -Recurse -Force

# Mac/Linux
cp -r ./odoo ~/.local/share/openclaw/skills/
```

**2. Configure Odoo connection:**

Edit `config.json` in the installed skill folder with your Odoo credentials:

```json
{
  "url": "http://your-odoo-url:8069",
  "db": "your_database_name",
  "username": "your_email@company.com",
  "api_key": "your_odoo_api_key",
  "timeout": 60
}
```

**How to get your API key:**
1. Log in to Odoo
2. Go to Settings → Users & Companies → Users
3. Open your user record
4. Scroll to "Access Tokens"
5. Click "Generate Token"
6. Copy and paste into config.json

**3. Test the connection:**

```powershell
# From the skill directory
python -c "import sys; sys.path.insert(0, '.'); from odoo_skill import OdooClient; client = OdooClient.from_env(); print(client.authenticate())"
```

If you see `uid=X`, the connection works!

---

## Verifying Installation

After installation, the skill should appear when you ask OpenClaw:

**In chat:**
```
You: "Do you have access to Odoo?"
OpenClaw: "Yes! I can see the odoo skill. I can help you with Sales, CRM, Purchasing, Inventory, HR, Projects, Fleet, and more."
```

**Or check manually:**

The skill file should exist at:
- **Windows:** `C:\Users\<YourName>\AppData\Roaming\npm\node_modules\openclaw\skills\odoo\SKILL.md`
- **Mac:** `~/Library/Application Support/openclaw/skills/odoo/SKILL.md`
- **Linux:** `~/.local/share/openclaw/skills/odoo/SKILL.md`

---

## Usage

Once installed, just ask OpenClaw in natural language:

**Examples:**
- "Create a quotation for Acme Corp with 10 Widgets at $50 each"
- "Show me all draft quotations"
- "Create a lead for Rocky, email rocky@example.com"
- "What products are low on stock?"
- "Create employee John Doe in Engineering department"
- "Log 3 hours on task #42"

See `SKILL.md` for full command reference (30+ examples).

---

## Troubleshooting

### Skill Not Found
- Restart OpenClaw: `openclaw gateway restart` (if restart is enabled)
- Or restart the OpenClaw process manually
- Check the SKILL.md file exists in the correct location

### Connection Errors
- Verify config.json has correct URL, database, username, api_key
- Check your Odoo server is running
- Regenerate the API key if authentication fails

### Missing Dependencies
- Python 3.10+ required
- No external dependencies needed (uses built-in xmlrpc.client)

---

## Support

For issues or questions:
- Check `SKILL.md` for documentation
- Check `README.md` for setup guide
- Check `TEST_RESULTS.md` for known issues

---

**Version:** 1.0.0  
**Last Updated:** 2026-02-09  
**OpenClaw Version:** Compatible with all versions  
**Odoo Version:** 19.0 (may work with 17-18 with field adjustments)
