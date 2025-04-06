#!/bin/sh
#
# entrypoint.sh (NGINX)
# - NGINX設定ファイルのDOMAIN_NAME等を置換
# - daemon offで起動

CONFIG_FILE="/etc/nginx/conf.d/default.conf"

# 環境変数: DOMAIN_NAME (docker-compose.yml / .env で設定)
if [ -n "${DOMAIN_NAME}" ]; then
    echo ">> Replacing SERVER_NAME in default.conf with '${DOMAIN_NAME}'"
    sed -i "s/server_name .*;/server_name ${DOMAIN_NAME};/" "${CONFIG_FILE}"
fi

# その他TLS設定は default.conf 側で ssl_protocols TLSv1.2 TLSv1.3; などを指定済み
# 証明書(inception.crt/inception.key)は Dockerfileで生成またはコピー済み想定

echo ">> Starting NGINX..."
exec nginx -g 'daemon off;'
