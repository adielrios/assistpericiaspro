#!/bin/bash

# Cores para visualização
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Verificador de Status do AssistPericias Pro  ${NC}"
echo -e "${BLUE}=================================================${NC}"

# Listar aplicativos no DigitalOcean
echo -e "\n${YELLOW}Procurando seu aplicativo no DigitalOcean...${NC}"
APP_INFO=$(doctl apps list --format ID,Spec.Name,DefaultIngress --no-header | grep -i "assistpericias")

# Verificar se encontrou algum aplicativo
if [ -z "$APP_INFO" ]; then
    echo -e "${RED}❌ Nenhum aplicativo encontrado com o nome assistpericias.${NC}"
    echo -e "${YELLOW}Listando todos os aplicativos disponíveis:${NC}"
    doctl apps list --format ID,Spec.Name,DefaultIngress --no-header
    
    echo -e "\n${YELLOW}Para verificar um aplicativo específico, insira o ID do aplicativo:${NC}"
    read -p "> " APP_ID
    
    if [ -z "$APP_ID" ]; then
        echo -e "${RED}❌ Nenhum ID fornecido. Saindo.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Aplicativo encontrado:${NC}"
    echo -e "${BLUE}$APP_INFO${NC}"
    
    # Extrair APP_ID e URL
    APP_ID=$(echo $APP_INFO | awk '{print $1}')
    APP_URL=$(echo $APP_INFO | awk '{print $3}')
fi

# Verificar se temos APP_URL
if [ -z "$APP_URL" ]; then
    # Obter URL do aplicativo
    APP_URL=$(doctl apps get $APP_ID --format DefaultIngress --no-header)
    
    if [ -z "$APP_URL" ]; then
        echo -e "${RED}❌ Não foi possível obter a URL do aplicativo.${NC}"
        echo -e "${YELLOW}Verificando status através do painel de controle...${NC}"
        
        echo -e "\nAcessando painel de controle: ${BLUE}https://cloud.digitalocean.com/apps/$APP_ID${NC}"
        
        # Tentar abrir no navegador
        open "https://cloud.digitalocean.com/apps/$APP_ID" 2>/dev/null || \
            echo -e "${YELLOW}Abra o link acima no seu navegador.${NC}"
        
        exit 0
    fi
fi

echo -e "\n${YELLOW}Informações do aplicativo:${NC}"
echo -e "ID do aplicativo: ${BLUE}$APP_ID${NC}"
echo -e "URL do aplicativo: ${BLUE}$APP_URL${NC}"
echo -e "Painel de controle: ${BLUE}https://cloud.digitalocean.com/apps/$APP_ID${NC}"

# Verificar status do aplicativo
echo -e "\n${YELLOW}Verificando status do aplicativo...${NC}"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL")

if [ "$HTTP_STATUS" == "200" ]; then
    echo -e "${GREEN}✅ Aplicativo está online (HTTP 200)${NC}"
else
    echo -e "${RED}❌ Aplicativo retornou código HTTP $HTTP_STATUS${NC}"
    
    # Verificar implantação
    echo -e "\n${YELLOW}Verificando status da implantação...${NC}"
    DEPLOYMENT_INFO=$(doctl apps list-deployments $APP_ID --format ID,Phase,Progress,Created --no-header | head -1)
    
    if [ -n "$DEPLOYMENT_INFO" ]; then
        echo -e "${BLUE}Última implantação:${NC}"
        echo -e "${BLUE}$DEPLOYMENT_INFO${NC}"
    else
        echo -e "${RED}❌ Não foi possível obter informações de implantação.${NC}"
    fi
fi

# Verificar API de status, se o aplicativo estiver online
if [ "$HTTP_STATUS" == "200" ]; then
    echo -e "\n${YELLOW}Verificando API de status...${NC}"
    API_RESULT=$(curl -s "$APP_URL/api/status")
    echo "$API_RESULT" | grep -q "online"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ API de status está online${NC}"
        echo -e "${BLUE}$API_RESULT${NC}"
    else
        echo -e "${YELLOW}⚠️ API de status não está respondendo como esperado${NC}"
        echo -e "${BLUE}Resposta: $API_RESULT${NC}"
    fi
fi

# Verificar domínio personalizado
echo -e "\n${YELLOW}Verificando domínio personalizado...${NC}"
DOMAIN_INFO=$(doctl apps domain list $APP_ID --format Domain,DNSRecord --no-header 2>/dev/null)

if [ -n "$DOMAIN_INFO" ]; then
    echo -e "${GREEN}✅ Domínio configurado:${NC}"
    echo -e "${BLUE}$DOMAIN_INFO${NC}"
    
    # Extrair o domínio
    DOMAIN=$(echo "$DOMAIN_INFO" | awk '{print $1}')
    
    # Verificar propagação DNS
    echo -e "\n${YELLOW}Verificando propagação DNS para $DOMAIN...${NC}"
    DNS_CHECK=$(dig +short $DOMAIN)
    
    if [ -n "$DNS_CHECK" ]; then
        echo -e "${GREEN}✅ DNS está configurado para $DOMAIN${NC}"
        echo -e "${BLUE}Apontando para: $DNS_CHECK${NC}"
        
        # Verificar acessibilidade
        echo -e "\n${YELLOW}Verificando acessibilidade do domínio...${NC}"
        DOMAIN_HTTP="https://$DOMAIN"
        DOMAIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN_HTTP")
        
        if [ "$DOMAIN_STATUS" == "200" ]; then
            echo -e "${GREEN}✅ Domínio está acessível (HTTP 200)${NC}"
            echo -e "${BLUE}$DOMAIN_HTTP${NC}"
        else
            echo -e "${YELLOW}⚠️ Domínio retornou código HTTP $DOMAIN_STATUS${NC}"
            echo -e "${YELLOW}A propagação DNS pode levar até 48 horas.${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️ DNS ainda não está propagado para $DOMAIN${NC}"
        echo -e "${YELLOW}Configure o registro CNAME no registro.br:${NC}"
        echo -e "${BLUE}$DOMAIN_INFO${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Nenhum domínio personalizado configurado.${NC}"
    echo -e "${YELLOW}Deseja configurar o domínio www.assistpericias.com.br? (s/n)${NC}"
    read -p "> " CONFIG_DOMAIN
    
    if [[ "$CONFIG_DOMAIN" == "s" ]]; then
        # Adicionar domínio
        doctl apps domain add $APP_ID "www.assistpericias.com.br"
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Falha ao adicionar domínio.${NC}"
        else
            echo -e "${GREEN}✅ Domínio adicionado!${NC}"
            echo -e "${YELLOW}Importante: Configure o DNS no registro.br:${NC}"
            
            # Obter informações do domínio
            DOMAIN_INFO=$(doctl apps domain list $APP_ID --format Domain,DNSRecord --no-header)
            echo -e "${BLUE}$DOMAIN_INFO${NC}"
            
            echo -e "\nAdicione este registro CNAME no seu painel do registro.br."
        fi
    fi
fi

# Verificar variáveis de ambiente configuradas
echo -e "\n${YELLOW}Verificando variáveis de ambiente...${NC}"
ENV_VARS=$(doctl apps get $APP_ID --format Spec.Services.0.Envs --no-header 2>/dev/null)

if [ -n "$ENV_VARS" ]; then
    echo -e "${GREEN}✅ Variáveis de ambiente configuradas:${NC}"
    # Exibir apenas as chaves das variáveis, não os valores
    echo "$ENV_VARS" | jq -r '.[].key' 2>/dev/null || echo "$ENV_VARS"
else
    echo -e "${YELLOW}⚠️ Não foi possível verificar variáveis de ambiente.${NC}"
fi

# Fornecer comandos úteis
echo -e "\n${YELLOW}Comandos úteis:${NC}"
echo -e "${BLUE}doctl apps get $APP_ID${NC} - Ver detalhes do aplicativo"
echo -e "${BLUE}doctl apps logs $APP_ID${NC} - Ver logs do aplicativo"
echo -e "${BLUE}doctl apps list-deployments $APP_ID${NC} - Listar implantações"
echo -e "${BLUE}doctl apps create-deployment $APP_ID${NC} - Criar nova implantação"

echo -e "\n${BLUE}=================================================${NC}"
echo -e "${GREEN}Verificação concluída!${NC}"
echo -e "${BLUE}=================================================${NC}"

echo -e "\n${YELLOW}Abrir painel de controle no navegador? (s/n)${NC}"
read -p "> " OPEN_PANEL

if [[ "$OPEN_PANEL" == "s" ]]; then
    open "https://cloud.digitalocean.com/apps/$APP_ID" 2>/dev/null || \
        echo -e "${YELLOW}Abra manualmente: ${BLUE}https://cloud.digitalocean.com/apps/$APP_ID${NC}"
fi
