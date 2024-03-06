# Stage 1
FROM node:20.10-alpine AS development

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

WORKDIR /home/node/app

COPY --chown=node:node package*.json ./
RUN npm ci --no-audit --force
COPY --chown=node:node tsconfig*.json nest-cli.json ./
COPY --chown=node:node src/ src/

USER node

# Stage 2
FROM development AS build
ENV NODE_OPTIONS="--max-old-space-size=1536"

WORKDIR /home/node/app

RUN npm run build

USER node

# Stage 3
FROM node:20.10-alpine AS production
ENV NODE_ENV=production

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

WORKDIR /home/node/app

COPY --chown=node:node package*.json ./
RUN  npm ci --ignore-scripts --production

USER node

# Stage 4
FROM node:20.10-alpine AS deploy
ENV NO_COLOR=true

RUN mkdir -p /home/node/app/node_modules && chown -R node:node /home/node/app

WORKDIR /home/node/app

COPY --chown=node:node --from=production home/node/app/node_modules/ node_modules/
COPY --chown=node:node --from=build home/node/app/dist/ dist/

CMD ["node", "dist/main.js"]

USER node
