FROM node:18-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install -ci
RUN npm run build

FROM nginx:stable-alpine
COPY --from=builder /app/public /usr/share/nginx/html