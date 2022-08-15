FROM node:16-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install -ci
COPY . .
RUN npm run build

FROM nginx:stable-alpine
COPY --from=builder /usr/src/app/public /usr/share/nginx/html
COPY --from=builder /usr/src/app/conf.d /etc/nginx