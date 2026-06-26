FROM node:20-alpine

RUN apk add --no-cache jq

RUN npm install -g @google/clasp@2.4.2

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
