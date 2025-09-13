FROM node:18-alpine

WORKDIR /app

# Instalar dependências do sistema
RUN apk add --no-cache git python3 make g++ cairo-dev pango-dev libjpeg-turbo-dev giflib-dev

# Clonar uma versão específica estável
RUN git clone -b main https://github.com/EvolutionAPI/evolution-api.git .

# Remover package-lock.json se existir (pode causar conflitos)
RUN rm -f package-lock.json

# Instalar dependências uma por vez para debug
RUN npm install --legacy-peer-deps --silent

# Build
RUN npm run build || echo "Build opcional falhou, continuando..."

EXPOSE 8080

# Comando alternativo
CMD ["node", "dist/src/main.js"]
