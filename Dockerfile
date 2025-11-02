# ========================================
# Stage 1: Base - Setup dependencies
# ========================================
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Copy package files
COPY src/package*.json ./

# Install all dependencies (including dev dependencies for testing and building)
RUN npm install

# ========================================
# Stage 2: Test - Run unit tests
# ========================================
FROM base AS test

# Copy source code
COPY src/ ./

# Run tests with coverage
RUN npm test

# This stage validates the code but doesn't produce artifacts
# GitHub Actions can use: docker build --target test -t expense-backend:test .

# ========================================
# Stage 3: Build - Compile TypeScript
# ========================================
FROM base AS build

# Copy source code
COPY src/ ./

# Build TypeScript to JavaScript
RUN npm run build

# Verify build output exists
RUN ls -la dist/

# This stage produces the compiled JavaScript in /app/dist
# GitHub Actions can use: docker build --target build -t expense-backend:build .

# ========================================
# Stage 4: Production - Prepare for deployment
# ========================================
FROM node:20-alpine AS production

WORKDIR /app

# Copy package files and install production dependencies only
COPY src/package*.json ./
RUN npm install --omit=dev

# Copy compiled code from build stage
COPY src/dist ./dist

# Create artifacts structure for Terraform
RUN mkdir -p /app/artifacts/expenses && \
    mkdir -p /app/artifacts/nodejs

# Copy Lambda functions (.js files) and rename to .mjs
RUN for func in /app/dist/expenses/*.js; do \
        if [ -f "$func" ]; then \
            funcname=$(basename "$func" .js); \
            cp "$func" "/app/artifacts/expenses/${funcname}.mjs"; \
        fi \
    done

# Copy shared dependencies for Lambda Layer
RUN cp -r /app/dist/services /app/artifacts/nodejs/ && \
    cp -r /app/dist/utils /app/artifacts/nodejs/ && \
    cp -r /app/node_modules /app/artifacts/nodejs/

# List all artifacts for verification
RUN echo "=== Artifacts Structure ===" && \
    ls -lah /app/artifacts/ && \
    echo "=== Lambda Functions ===" && \
    ls -lah /app/artifacts/expenses/ && \
    echo "=== Lambda Layer ===" && \
    ls -lah /app/artifacts/nodejs/ && \
    echo "=== Verify node_modules exists ===" && \
    ls -lah /app/artifacts/nodejs/node_modules/ | head -20

# Default command
CMD ["node", "--version"]

# GitHub Actions can use: docker build --target production -t expense-backend:prod .
# Then extract artifacts: docker create --name temp expense-backend:prod && docker cp temp:/app/artifacts ./artifacts && docker rm temp
# Note: Terraform will handle zipping these files using source_path configuration

