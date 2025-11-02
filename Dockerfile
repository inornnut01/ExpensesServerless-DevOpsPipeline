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
# Stage 4: Production - Package for deployment
# ========================================
FROM node:20-alpine AS production

WORKDIR /app

# Copy package files and install production dependencies only
COPY src/package*.json ./
RUN npm install --omit=dev

# Copy compiled code from build stage
COPY src/dist ./dist

# Copy any additional files needed for deployment
COPY src/tsconfig.json ./

# Install zip utility for creating Lambda deployment packages
RUN apk add --no-cache zip

# Create deployment artifacts structure
RUN mkdir -p /app/artifacts

# Package Lambda functions (adjust paths as needed for your Lambda functions)
# Each Lambda function should be zipped with its dependencies
RUN cd dist && \
    for func in expenses/*.js; do \
        if [ -f "$func" ]; then \
            funcname=$(basename "$func" .js); \
            mkdir -p "/app/artifacts/$funcname"; \
            mv "$func" "/app/artifacts/$funcname/${funcname}.mjs"; \
            cd "/app/artifacts/$funcname" && zip -r "../${funcname}.zip" . && cd /app/dist; \
        fi \
    done

# Package services and utils as Lambda Layer
RUN mkdir -p /app/artifacts/layer/nodejs && \
    cp -r dist/services /app/artifacts/layer/nodejs/ && \
    cp -r dist/utils /app/artifacts/layer/nodejs/ && \
    cd /app/artifacts/layer && zip -r ../lambda-layer.zip nodejs/

# List all artifacts for verification
RUN ls -lah /app/artifacts/

# Default command
CMD ["node", "--version"]

# GitHub Actions can use: docker build --target production -t expense-backend:prod .
# Then extract artifacts: docker create --name temp expense-backend:prod && docker cp temp:/app/artifacts ./artifacts && docker rm temp

