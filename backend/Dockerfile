FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .
# Change this to 8080 for GCP compatibility!
EXPOSE 8080
CMD ["npm", "start"]