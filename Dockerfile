# --- STAGE 1: Build the React + Vite Frontend ---
FROM node:20-alpine AS frontend-builder
WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package*.json ./
RUN npm ci

# Copy all frontend source files and compile them into static html/js
COPY frontend/ ./
RUN npm run build

# --- STAGE 2: Setup the Express Backend & Combine ---
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production

# Copy backend package files and install ONLY production dependencies (No devDependencies)
COPY backend/package*.json ./
RUN npm ci --only=production

# Copy backend source code (including your server.js)
COPY backend/ ./
# New line matching your exact server.js:
COPY --from=frontend-builder /app/frontend/dist ./dist

EXPOSE 3000
CMD ["node", "server.js"]