FROM node:20-alpine AS builder

RUN apk update && \
    apk add --no-cache git ffmpeg wget curl bash openssl dos2unix

LABEL version="2.3.1" description="Api to control whatsapp features through http requests."
LABEL maintainer="Davidson Gomes" git="https://github.com/DavidsonGomes"
LABEL contact="contato@evolution-api.com"

WORKDIR /evolution

# Clonar o repositório completo primeiro
RUN git clone https://github.com/EvolutionAPI/evolution-api.git temp && \
    cp -r temp/* . && \
    cp -r temp/.* . 2>/dev/null || true && \
    rm -rf temp

# Agora os arquivos existem, podemos prosseguir com o build original
RUN npm ci --silent

RUN chmod +x ./Docker/scripts/* && dos2unix ./Docker/scripts/*
RUN ./Docker/scripts/generate_database.sh
RUN npm run build

FROM node:20-alpine AS final

RUN apk update && \
    apk add tzdata ffmpeg bash openssl

ENV TZ=America/Sao_Paulo
ENV DOCKER_ENV=true

WORKDIR /evolution

COPY --from=builder /evolution/package.json ./package.json
COPY --from=builder /evolution/package-lock.json ./package-lock.json
COPY --from=builder /evolution/node_modules ./node_modules
COPY --from=builder /evolution/dist ./dist
COPY --from=builder /evolution/prisma ./prisma
COPY --from=builder /evolution/manager ./manager
COPY --from=builder /evolution/public ./public
COPY --from=builder /evolution/.env ./.env
COPY --from=builder /evolution/Docker ./Docker
COPY --from=builder /evolution/runWithProvider.js ./runWithProvider.js
COPY --from=builder /evolution/tsup.config.ts ./tsup.config.ts

ENV DOCKER_ENV=true

EXPOSE 8080

ENTRYPOINT ["/bin/bash", "-c", ". ./Docker/scripts/deploy_database.sh && npm run start:prod"]
