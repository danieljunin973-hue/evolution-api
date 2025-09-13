FROM node:18-alpine

WORKDIR /app

# Instalar dependências do sistema necessárias
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    libc6-compat \
    pkgconfig \
    pixman-dev \
    cairo-dev \
    pango-dev \
    libjpeg-turbo-dev \
    giflib-dev

# Clonar o repositório
RUN git clone https://github.com/EvolutionAPI/evolution-api.git .

# Limpar cache do npm e reinstalar
RUN npm cache clean --force

# Usar npm install ao invés de npm ci
RUN npm install --production=false --silent

# Fazer build se necessário
RUN npm run build || echo "Build step skipped"

# Expor porta
EXPOSE 8080

# Comando para iniciar
CMD ["npm", "start"]
