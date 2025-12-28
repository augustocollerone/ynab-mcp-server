[![MseeP.ai Security Assessment Badge](https://mseep.net/mseep-audited.png)](https://mseep.ai/app/calebl-ynab-mcp-server)

# ynab-mcp-server
[![smithery badge](https://smithery.ai/badge/@calebl/ynab-mcp-server)](https://smithery.ai/server/@calebl/ynab-mcp-server)
[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/YNAB-MCP?referralCode=your-code)

A Model Context Protocol (MCP) server built with mcp-framework. This MCP provides tools
for interacting with your YNAB budgets setup at https://ynab.com

<a href="https://glama.ai/mcp/servers/@calebl/ynab-mcp-server">
  <img width="380" height="200" src="https://glama.ai/mcp/servers/@calebl/ynab-mcp-server/badge" alt="YNAB Server MCP server" />
</a>

In order to have an AI interact with this tool, you will need to get your Personal Access Token
from YNAB: https://api.ynab.com/#personal-access-tokens. When adding this MCP server to any
client, you will need to provide your personal access token as YNAB_API_TOKEN. **This token
is never directly sent to the LLM.** It is stored privately in an environment variable for
use with the YNAB api.

## Setup
Specify env variables:
* YNAB_API_TOKEN (required) - Your YNAB Personal Access Token
* YNAB_BUDGET_ID (optional) - Default budget ID to use
* MCP_TRANSPORT (optional) - Transport mode: `stdio` (default) or `http`
* PORT (optional) - HTTP server port when using http transport (default: 3000)
* MCP_API_KEY (optional) - API key for HTTP authentication

## Goal
The goal of the project is to be able to interact with my YNAB budget via an AI conversation.
There are a few primary workflows I want to enable:

## Workflows:
### First time setup
* be prompted to select your budget from your available budgets. If you try to use another
tool first, this prompt should happen asking you to set your default budget.
  * Tools needed: ListBudgets
### Manage overspent categories
### Adding new transactions
### Approving transactions
### Check total monthly spending vs total income
### Auto-distribute ready to assign funds based on category targets

## Current state
Available tools:
* ListBudgets - lists available budgets on your account
* BudgetSummary - provides a summary of categories that are underfunded and accounts that are low
* GetUnapprovedTransactions - retrieve all unapproved transactions
* CreateTransaction - creates a transaction for a specified budget and account.
  * example prompt: `Add a transaction to my Ally account for $3.98 I spent at REI today`
  * requires GetBudget to be called first so we know the account id
* ApproveTransaction - approves an existing transaction in your YNAB budget
  * requires a transaction ID to approve
  * can be used in conjunction with GetUnapprovedTransactions to approve pending transactions
  * After calling get unapproved transactions, prompt: `approve the transaction for $6.95 on the Apple Card`

Next:
* be able to approve multiple transactions with 1 call
* updateCategory tool - or updateTransaction more general tool if I can get optional parameters to work correctly with zod & mcp framework
* move off of mcp framework to use the model context protocol sdk directly?


## Quick Start

```bash
# Install dependencies
npm install

# Build the project
npm run build

```

## Project Structure

```
ynab-mcp-server/
├── src/
│   ├── tools/        # MCP Tools
│   └── index.ts      # Server entry point
├── .cursor/
│   └── rules/        # Cursor AI rules for code generation
├── package.json
└── tsconfig.json
```

## Adding Components

The YNAB sdk describes the available api endpoints: https://github.com/ynab/ynab-sdk-js.

YNAB open api specification is here: https://api.ynab.com/papi/open_api_spec.yaml. This can
be used to prompt an AI to generate a new tool. Example prompt for Cursor Agent:

```
create a new tool based on the readme and this openapi doc: https://api.ynab.com/papi/open_api_spec.yaml

The new tool should get the details for a single budget
```

You can add more tools using the CLI:

```bash
# Add a new tool
mcp add tool my-tool

# Example tools you might create:
mcp add tool data-processor
mcp add tool api-client
mcp add tool file-handler
```

## Tool Development

Example tool structure:

```typescript
import { MCPTool } from "mcp-framework";
import { z } from "zod";

interface MyToolInput {
  message: string;
}

class MyTool extends MCPTool<MyToolInput> {
  name = "my_tool";
  description = "Describes what your tool does";

  schema = {
    message: {
      type: z.string(),
      description: "Description of this input parameter",
    },
  };

  async execute(input: MyToolInput) {
    // Your tool logic here
    return `Processed: ${input.message}`;
  }
}

export default MyTool;
```

## Publishing to npm

1. Update your package.json:
   - Ensure `name` is unique and follows npm naming conventions
   - Set appropriate `version`
   - Add `description`, `author`, `license`, etc.
   - Check `bin` points to the correct entry file

2. Build and test locally:
   ```bash
   npm run build
   npm link
   ynab-mcp-server  # Test your CLI locally
   ```

3. Login to npm (create account if necessary):
   ```bash
   npm login
   ```

4. Publish your package:
   ```bash
   npm publish
   ```

After publishing, users can add it to their claude desktop client (read below) or run it with npx


## Using with Claude Desktop

### Installing via Smithery

To install YNAB Budget Assistant for Claude Desktop automatically via [Smithery](https://smithery.ai/server/@calebl/ynab-mcp-server):

```bash
npx -y @smithery/cli install @calebl/ynab-mcp-server --client claude
```

### Local Development

Add this configuration to your Claude Desktop config file:

**MacOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "ynab-mcp-server": {
      "command": "node",
      "args":["/absolute/path/to/ynab-mcp-server/dist/index.js"]
    }
  }
}
```

### After Publishing

Add this configuration to your Claude Desktop config file:

**MacOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "ynab-mcp-server": {
      "command": "npx",
      "args": ["ynab-mcp-server"]
    }
  }
}
```

### Other MCP Clients
Check https://modelcontextprotocol.io/clients for other available clients.

## Transport Modes

This server supports two transport modes:

| Mode | Use Case | Environment Variable |
|------|----------|---------------------|
| **stdio** (default) | Local use with Claude Desktop, Claude Code, or other local MCP clients | `MCP_TRANSPORT=stdio` or unset |
| **http** | Remote/cloud deployment, Docker containers, shared servers | `MCP_TRANSPORT=http` |

### When to Use Each Mode

- **stdio**: You're running the server locally on the same machine as your MCP client. This is the simplest setup and requires no network configuration.
- **http**: You want to run the server on a remote machine, in Docker, or share it across multiple clients. Requires network access to the server.

## Docker Deployment (HTTP Transport)

When running in Docker, the server uses HTTP transport to accept remote connections.

### Quick Start with Docker

```bash
# Build the image
docker build -t ynab-mcp-server .

# Run the container
docker run -d --name ynab-mcp \
  -p 3000:3000 \
  -e YNAB_API_TOKEN=your_token_here \
  -e YNAB_BUDGET_ID=your_budget_id \
  ynab-mcp-server
```

### Using Docker Compose

1. Create a `.env` file with your credentials:
   ```bash
   YNAB_API_TOKEN=your_api_token_here
   YNAB_BUDGET_ID=your_default_budget_id  # optional
   MCP_API_KEY=your_secure_api_key        # optional, see Authentication section
   ```

2. Run with Docker Compose:
   ```bash
   docker-compose up -d
   ```

3. The server will be available at `http://localhost:3000/mcp`

4. Verify it's running:
   ```bash
   curl http://localhost:3000/health
   # Should return: {"status":"ok","transport":"http"}
   ```

### HTTP Endpoints

When running with `MCP_TRANSPORT=http`, the server exposes:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/mcp` | POST | MCP JSON-RPC requests (tool calls, initialization) |
| `/mcp` | GET | SSE stream for server notifications |
| `/mcp` | DELETE | Session cleanup |
| `/health` | GET | Health check endpoint (returns `{"status":"ok","transport":"http"}`) |

### Authentication (Optional)

API key authentication is **optional** and disabled by default.

**When to enable it:**
- When exposing the server to the internet
- When running on a shared network
- When you want to restrict access to authorized clients only

**When you can skip it:**
- Running locally on your machine
- Running in a private network with trusted clients
- Behind a VPN or firewall that already handles authentication

**To enable authentication:**

1. Set the `MCP_API_KEY` environment variable:
   ```bash
   docker run -d \
     -e YNAB_API_TOKEN=your_token \
     -e MCP_API_KEY=your_secure_random_key \
     ynab-mcp-server
   ```

2. All requests to `/mcp` must include the Authorization header:
   ```
   Authorization: Bearer your_secure_random_key
   ```

3. Requests without a valid API key will receive a `401 Unauthorized` response.

**Note:** The `/health` endpoint does not require authentication, so load balancers and health checks can still work.

### Connecting Claude Code to HTTP Server

After starting the Docker container, add it to Claude Code:

```bash
# Without authentication
claude mcp add --transport http ynab-mcp-server http://localhost:3000/mcp --scope user

# With authentication (if MCP_API_KEY is set)
claude mcp add --transport http ynab-mcp-server http://localhost:3000/mcp \
  --header "Authorization: Bearer your_secure_random_key" --scope user
```

To verify it's connected:
```bash
claude mcp list
```

### Cloud Deployment

#### Railway (One-Click Deploy)

Click the button at the top of this README or use:

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/YNAB-MCP?referralCode=your-code)

After clicking, Railway will prompt you to configure these environment variables:

| Variable | Required | Description |
|----------|----------|-------------|
| `YNAB_API_TOKEN` | Yes | Your YNAB Personal Access Token |
| `YNAB_BUDGET_ID` | No | Default budget ID (can be set later) |
| `MCP_API_KEY` | Recommended | API key for authenticating requests |

Once deployed, your server will be available at `https://your-app.railway.app/mcp`.

**Manual Railway deployment:**
```bash
railway init
railway up
# Set environment variables in Railway dashboard
```

#### Creating Your Own Railway Template

If you fork this repo and want your own deploy button:

1. Push your fork to GitHub
2. Go to [Railway Templates](https://railway.com/workspace/templates)
3. Click "New Template" → Add your GitHub repo
4. Configure required variables: `YNAB_API_TOKEN`, `YNAB_BUDGET_ID`, `MCP_API_KEY`
5. Publish the template and copy the template URL
6. Update the deploy button in your README with your template URL

**Fly.io:**
```bash
fly launch
fly secrets set YNAB_API_TOKEN=xxx YNAB_BUDGET_ID=xxx MCP_API_KEY=xxx
fly deploy
```

### Security Best Practices

1. **Always use HTTPS in production** - Use a reverse proxy like Caddy, nginx, or your cloud provider's load balancer
2. **Set a strong `MCP_API_KEY`** - Use a long, random string (e.g., `openssl rand -hex 32`)
3. **Never expose `YNAB_API_TOKEN`** - This token has full access to your YNAB account
4. **Use environment variables** - Never hardcode secrets in your code or Dockerfile
5. **Restrict network access** - Use firewalls or private networks when possible

## Building and Testing

1. Make changes to your tools
2. Run `npm run build` to compile
3. The server will automatically load your tools on startup

## Learn More

- [MCP Framework Github](https://github.com/QuantGeekDev/mcp-framework)
- [MCP Framework Docs](https://mcp-framework.com)
