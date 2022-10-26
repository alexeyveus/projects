FROM node:14-slim

COPY . /app

WORKDIR /app

RUN npm run test

RUN npm install

EXPOSE 3000

ENTRYPOINT [ "npm", "start" ]