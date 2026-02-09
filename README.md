# Odoo ERP Connector for OpenClaw

**Full-featured Odoo 19 integration for OpenClaw. Control your entire business via chat commands.**

## Quick Start (30 seconds)

### 1. Run the installer

```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```

The script will:
- Verify Python 3.10+
- Prompt for your Odoo connection details
- Install dependencies
- Test the connection
- Create `config.json`

### 2. Configure OpenClaw

Point your OpenClaw skill at the `odoo_skill` folder:

```yaml
skills:
  - name: odoo
    type: python
    path: ./odoo_skill
    entrypoint: smart_actions.SmartActionHandler
```

### 3. Start using it

```
You: "Create a quotation for Acme Corp with 10 Widgets at $50 each"
OpenClaw: "✅ Created quotation QT-001 for Acme Corp with 10 × Widgets at $50"
```

---

## Manual Setup

### Prerequisites

- **Python 3.10+** (`python --version`)
- **Odoo 19 instance** (on-premise or cloud)
- **API key** from your Odoo user (Settings → Users → Access Tokens)

### Step 1: Get Your API Key

1. Log into your Odoo instance
2. Click your profile icon (top-right)
3. Go to **Settings**
4. Scroll to **Access Tokens** section
5. Click **Generate Token**
6. Copy the token

### Step 2: Install Dependencies

```bash
cd OdooConnector
pip install -r requirements.txt
```

### Step 3: Create config.json

Copy `config.template.json` to `config.json` and fill in your details:

```json
{
  "url": "http://localhost:8069",
  "db": "your_database_name",
  "username": "api_user@yourcompany.com",
  "api_key": "your_api_key_from_step_1",
  "timeout": 60,
  "max_retries": 3
}
```

**Configuration options:**

| Field | Description | Example |
|-------|-------------|---------|
| `url` | Odoo instance URL | `http://localhost:8069` or `https://company.odoo.com` |
| `db` | Database name | `production` or `wizard` |
| `username` | User email | `api_user@company.com` |
| `api_key` | API token from user settings | 64-character hex string |
| `timeout` | Request timeout (seconds) | `60` |
| `max_retries` | Network retry attempts | `3` |
| `poll_interval` | Webhook check interval | `60` |

### Step 4: Test Connection

```bash
python -c "from odoo_skill import OdooClient; client = OdooClient(); print(client.test_connection())"
```

Expected output:
```
{'status': 'connected', 'server_version': '19.0', 'user': 'api_user@company.com'}
```

---

## Usage

### Command Syntax

All commands follow natural language patterns:

```
"[Action] [resource] for/with [details]"
```

Examples:
- "Create a **quotation** for **Acme Corp** with **10 Widgets at $50 each**"
- "Show me **unpaid invoices** from the **past 30 days**"
- "Create **task** 'Fix login' in **Website Redesign** project"

### Module Reference

#### Sales & CRM

| Command | What It Does |
|---------|-------------|
| `Create quotation for [customer] with [quantity] [product] at $[price]` | Create a draft sales quotation |
| `Confirm sales order [number]` | Move order from draft → confirmed |
| `Show draft quotations` | List all quotations in draft state |
| `What's the pipeline?` | Show sales pipeline by stage and revenue |
| `Create lead for [name] with email [email] and value $[amount]` | Create a sales lead |
| `Move lead [number] to [stage]` | Advance lead through CRM pipeline |

#### Purchasing

| Command | What It Does |
|---------|-------------|
| `Create PO for [vendor] with [qty] [product] at $[price]` | Create purchase order |
| `Confirm purchase order [number]` | Move PO to confirmed state |
| `Show pending purchase orders` | List all unconfirmed POs |
| `What orders are overdue?` | Find POs past due date |
| `Get vendor history for [vendor]` | Show all POs from vendor |

#### Inventory & Products

| Command | What It Does |
|---------|-------------|
| `Create product [name] with price $[amount]` | Create new product |
| `Show stock levels for [product]` | Check quantity on hand |
| `What products are low on stock?` | List products below reorder point |
| `Search for [product]` | Find product by name/code |
| `Set min stock [product] to [quantity]` | Update reorder point |

#### Invoicing

| Command | What It Does |
|---------|-------------|
| `Create invoice for [customer] with [qty] [product] at $[price]` | Create customer invoice |
| `Show unpaid invoices` | List all draft/open invoices |
| `What invoices are overdue?` | List past-due invoices |
| `Post invoice [number]` | Move invoice to posted state |
| `Show revenue for [month]` | Sum posted invoices by month |

#### Projects & Tasks

| Command | What It Does |
|---------|-------------|
| `Create project [name]` | Create new project |
| `Create task [name] in [project]` | Add task to project |
| `Show tasks for [project]` | List all tasks in project |
| `Log [hours] hours on task [number]` | Log timesheet entry |
| `What's the status of [project]?` | Show project progress |

#### HR

| Command | What It Does |
|---------|-------------|
| `Create employee [name] in [department]` | Add employee |
| `Show employees in [department]` | List department members |
| `Create expense report for $[amount]` | Submit expense claim |
| `What leave requests are pending?` | List pending time-off |
| `Show attendance for [employee]` | View attendance records |

#### Fleet

| Command | What It Does |
|---------|-------------|
| `Create vehicle [license plate]` | Register new fleet vehicle |
| `Log odometer [value] for vehicle [number]` | Record mileage |
| `Show vehicles needing service` | List fleet maintenance due |
| `What's the fleet maintenance cost?` | Total maintenance expenses |

#### Manufacturing

| Command | What It Does |
|---------|-------------|
| `Create BOM for [product] with [components]` | Define Bill of Materials |
| `Create MO to produce [qty] [product]` | Create manufacturing order |
| `Confirm manufacturing order [number]` | Move MO to confirmed state |
| `Show components for [product]` | List BOM components |

#### Calendar

| Command | What It Does |
|---------|-------------|
| `Create meeting [title] tomorrow at [time] for [duration]` | Schedule event |
| `Show my meetings for next week` | List upcoming events |
| `What do I have on [date]?` | Show events for a date |

---

## Features

### Smart Actions (Fuzzy Matching)

The connector intelligently handles incomplete requests:

**Example 1: Create quotation for new customer**
```
Input: "Create quotation for Rocky with product Rock"

Process:
✓ Search for customer "Rocky" → Not found
✓ Create new customer "Rocky" (auto)
✓ Search for product "Rock" → Not found  
✓ Create new product "Rock" (auto)
✓ Create quotation linking both

Output: "Created quotation QT-001 for new customer Rocky with 1 × Rock at $0.00"
```

**Example 2: Create lead with auto-partner**
```
Input: "Create lead for Acme with $50k expected value"

Process:
✓ Search for customer "Acme" → Found (exists)
✓ Create lead linked to existing Acme

Output: "Created lead for existing customer Acme with $50k expected value"
```

### Benefits

- **No IDs needed** — Use names instead of Odoo record IDs
- **Case-insensitive** — "ACME CORP", "acme corp", "Acme Corp" all match
- **Auto-creation** — Missing references created automatically
- **Transparent feedback** — Know what was found vs. created

### Error Recovery

The connector automatically retries on network failures:

```python
# Built-in retry logic (3 attempts)
- Network timeout → retry with exponential backoff
- Transient error → retry after delay
- Permission error → fail immediately with clear message
```

---

## Python API

### Import & Initialize

```python
from odoo_skill import OdooClient, SmartActionHandler

# Load config from config.json
client = OdooClient.from_config("config.json")

# Or use environment variables
client = OdooClient()  # Loads from .env or config.json

# Verify connection
status = client.test_connection()
print(f"Connected to Odoo {status['server_version']}")
```

### Smart Actions (High-Level)

```python
from odoo_skill import SmartActionHandler

smart = SmartActionHandler(client)

# Create quotation (auto-finds/creates customer & products)
result = smart.smart_create_quotation(
    customer_name="Acme Corp",
    product_lines=[
        {"name": "Widget", "quantity": 10, "price_unit": 49.99}
    ]
)
print(result["summary"])

# Create purchase order (auto-finds/creates vendor & products)
result = smart.smart_create_purchase(
    vendor_name="Supplier XYZ",
    product_lines=[
        {"name": "Component A", "quantity": 500, "price_unit": 5.00}
    ]
)

# Create lead (auto-finds/creates partner)
result = smart.smart_create_lead(
    name="New Prospect",
    contact_name="John Doe",
    email="john@prospect.com",
    expected_revenue=100000.0
)

# Create task (auto-finds/creates project)
result = smart.smart_create_task(
    project_name="Website Redesign",
    task_name="Fix responsive design",
    description="Make site mobile-friendly"
)

# Create employee (auto-finds/creates department)
result = smart.smart_create_employee(
    name="Jane Smith",
    job_title="Senior Developer",
    department_name="Engineering"
)
```

### Ops Classes (Low-Level)

```python
from odoo_skill.models.sale_order import SaleOrderOps
from odoo_skill.models.partner import PartnerOps
from odoo_skill.models.inventory import InventoryOps

# Partner operations
partners = PartnerOps(client)
customers = partners.search_customers(query="Acme")
customer = partners.get_customer(customer_id=42)
partners.update_customer(42, city="New York")

# Sales operations
sales = SaleOrderOps(client)
order = sales.create_quotation(
    partner_id=42,
    lines=[{"product_id": 7, "quantity": 10, "price_unit": 49.99}]
)
orders = sales.search_orders(partner_id=42)
confirmed = sales.confirm_order(order["id"])

# Inventory operations
inventory = InventoryOps(client)
products = inventory.search_products("Widget")
stock = inventory.check_product_availability(product_id=7)
low_stock = inventory.get_low_stock_products(threshold=20)
```

### Error Handling

```python
from odoo_skill.errors import OdooError, OdooAuthError, OdooNotFoundError

try:
    result = smart.smart_create_quotation(
        customer_name="Acme",
        product_lines=[{"name": "Widget"}]
    )
except OdooAuthError as e:
    print(f"Authentication failed — check your API key: {e}")
except OdooNotFoundError as e:
    print(f"Record not found: {e}")
except OdooError as e:
    print(f"Odoo error: {e}")
```

---

## Response Format

All API calls return structured dictionaries:

### Smart Action Response Example

```python
{
  "summary": "Created quotation QT-001 for new customer Acme Corp with 1 × Widget",
  "order": {
    "id": 123,
    "name": "QT-001",
    "state": "draft",
    "partner_id": [456, "Acme Corp"],
    "amount_total": 49.99
  },
  "customer": {
    "created": True,
    "partner": {
      "id": 456,
      "name": "Acme Corp"
    }
  },
  "products": [
    {
      "created": False,
      "product": {
        "id": 7,
        "name": "Widget",
        "list_price": 49.99
      }
    }
  ]
}
```

---

## Troubleshooting

### Connection Issues

**Error:** `Connection refused` or `Cannot connect to [url]`

**Solution:**
1. Verify Odoo is running: `curl http://your-odoo-url/web`
2. Check firewall — port 8069 (or your port) must be accessible
3. Verify URL in `config.json` — remove trailing slashes

---

### Authentication Failed

**Error:** `Invalid username or api_key`

**Solution:**
1. Regenerate API key in Odoo: Settings → Users → Access Tokens
2. Verify username is the email (e.g., `api_user@company.com`)
3. Check database name matches exactly
4. Test with: `python test_auth.py`

---

### Field Not Found

**Error:** `Field 'xyz' does not exist`

**Solution:**
1. Field names are case-sensitive (e.g., `product_tmpl_id`, not `product_id`)
2. Check Odoo model definition: Settings → Technical → Models
3. Some fields are read-only (e.g., `state`, `amount_total`)
4. Some fields may not exist in Odoo 19 (check release notes)

---

### Timeout / Slow Requests

**Error:** `Timeout after 60 seconds`

**Solution:**
1. Increase `timeout` in `config.json` (e.g., 120 seconds)
2. Use filters to reduce result set: `limit`, `date_from`, `date_to`
3. Split large operations into smaller batches
4. Check Odoo server performance (long-running processes)

---

### Smart Action Issues

**Issue:** Fuzzy matching finds the wrong record

**Solution:**
1. Fuzzy matching is case-insensitive but exact name matching is preferred
2. For exact matches, use the low-level Ops API with record `id` directly
3. If multiple similar names exist, the first match is used

---

## Supported Modules

The connector works with 153+ Odoo modules:

**Core Modules**
- Sales Order Management
- CRM & Lead Management
- Purchase Management
- Inventory & Stock
- Invoicing & Accounting
- Projects & Tasks
- Human Resources
- Fleet Management
- Manufacturing (MRP)
- Calendar & Events
- eCommerce

**Plus 140+ additional modules** (see SKILL.md for full list)

---

## Advanced Configuration

### Environment Variables

Instead of `config.json`, set in `.env` or system environment:

```bash
export ODOO_URL="http://localhost:8069"
export ODOO_DB="production"
export ODOO_USERNAME="api_user@company.com"
export ODOO_API_KEY="your_api_key"
```

The client auto-loads from `.env` if `config.json` doesn't exist.

### Logging

Set log level in `config.json`:

```json
{
  "log_level": "DEBUG"
}
```

Levels: `DEBUG`, `INFO`, `WARNING`, `ERROR`

### Webhook Configuration

For real-time Odoo → OpenClaw sync (optional):

```json
{
  "webhook_port": 8070,
  "webhook_secret": "your_secret_key"
}
```

Then create webhook in Odoo: Settings → Technical → Webhooks

---

## Testing

### Run Integration Tests

```bash
# Full test suite (all modules)
python run_full_test.py

# Single test module
python -m pytest tests/test_sales.py -v

# With coverage
python -m pytest --cov=odoo_skill tests/
```

Test file: `run_full_test.py` (covers all major operations)

---

## Development

### Project Layout

```
OdooConnector/
├── odoo_skill/                 # Main package
│   ├── client.py              # Core OdooClient
│   ├── config.py              # Config loader
│   ├── smart_actions.py       # High-level API
│   ├── models/                # Module-specific Ops classes
│   │   ├── partner.py
│   │   ├── sale_order.py
│   │   ├── invoice.py
│   │   ├── inventory.py
│   │   ├── crm.py
│   │   ├── purchase.py
│   │   ├── project.py
│   │   ├── hr.py
│   │   ├── manufacturing.py
│   │   ├── calendar_ops.py
│   │   ├── fleet.py
│   │   └── ecommerce.py
│   └── utils/                 # Helpers
│       ├── formatting.py
│       └── validators.py
├── run_full_test.py           # Integration tests
├── config.json                # Your config (create from template)
├── config.template.json       # Config template
├── requirements.txt
├── README.md                  # This file
├── SKILL.md                   # Detailed skill reference
└── setup.ps1                  # Installer
```

### Adding Custom Operations

Extend the Ops classes in `odoo_skill/models/`:

```python
# odoo_skill/models/sale_order.py

class SaleOrderOps:
    def my_custom_operation(self, partner_id: int) -> dict:
        """Custom operation example."""
        return self.client.read("sale.order", partner_id)
```

Then use in smart actions:

```python
# odoo_skill/smart_actions.py

def smart_my_operation(self, ...):
    return self.sales.my_custom_operation(...)
```

---

## Support & Community

- **Issues:** [GitHub Issues](https://github.com/openclaw/odoo-connector/issues)
- **Discussions:** [GitHub Discussions](https://github.com/openclaw/odoo-connector/discussions)
- **Odoo Community:** [Odoo Forums](https://www.odoo.com/forum)

---

## License

This project is licensed under the MIT License — see `LICENSE` file for details.

---

**Version:** 2.0  
**Odoo:** 19.0+  
**Python:** 3.10+  
**Status:** Production Ready ✅

Last updated: 2026-02-09
