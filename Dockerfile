# ──────────────────────────────────────────────
# STAGE 1: deps
# Install ALL dependencies (including devDeps)
# This stage is discarded in the final image
# ──────────────────────────────────────────────
FROM node:22-alpine AS deps

WORKDIR /app

# Copy only package files first → better layer caching
# If source code changes but deps don't, Docker reuses this layer
COPY package*.json ./

RUN npm ci --include=dev


# ──────────────────────────────────────────────
# STAGE 2: test
# Run tests inside the builder — if tests fail,
# the entire Docker build fails (no broken image ships)
# ──────────────────────────────────────────────
FROM deps AS test

COPY . .

RUN npm test


# ──────────────────────────────────────────────
# STAGE 3: builder
# Build/prepare production assets
# ──────────────────────────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./

# Only install PRODUCTION dependencies
RUN npm ci --omit=dev


# ──────────────────────────────────────────────
# STAGE 4: production  ← this is the final image
# Minimal, hardened, no dev tools
# ──────────────────────────────────────────────
FROM node:22-alpine AS production

# Security best practice: don't run as root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy ONLY production node_modules from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy app source
COPY src/ ./src/
COPY package.json ./

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

USER appuser

# Expose port
EXPOSE 3000

# Healthcheck — Docker daemon monitors container health
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

ENV NODE_ENV=production

CMD ["node", "src/index.js"]
