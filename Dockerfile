# YNAB MCP Server Dockerfile
# Supports both stdio (local) and HTTP (remote) transports

FROM node:20-alpine

WORKDIR /app

# Install app dependencies
COPY package*.json ./
RUN npm ci --ignore-scripts

# Copy source code and build
COPY . .
RUN npm run build

# Set environment variables
ENV NODE_ENV=production
ENV MCP_TRANSPORT=http
ENV PORT=3000

# YNAB credentials (must be provided at runtime)
# ENV YNAB_API_TOKEN=""
# ENV YNAB_BUDGET_ID=""
# ENV MCP_API_KEY=""

# Expose the HTTP port
EXPOSE 3000

# Health check for HTTP mode
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Run the server
CMD ["node", "dist/index.js"]
