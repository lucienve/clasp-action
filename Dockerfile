FROM node:26-alpine

RUN apk add --no-cache jq

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

ENV PATH="/app/node_modules/.bin:${PATH}"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
