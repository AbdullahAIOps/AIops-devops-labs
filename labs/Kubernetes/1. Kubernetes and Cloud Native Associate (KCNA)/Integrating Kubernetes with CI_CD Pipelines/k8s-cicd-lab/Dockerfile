FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production

COPY . .
Expose 3000

USER node
CMD ["npm","start"]
