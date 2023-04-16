FROM node:19.8.1-alpine3.17

WORKDIR /usr/src/app

RUN npm install -g @nestjs/cli

COPY package*.json ./
COPY prisma ./prisma/

RUN npm install && npx prisma generate

COPY . .

CMD ["npm", "run", "start:dev"]
