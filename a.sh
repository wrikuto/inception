#!/bin/bash

# プロジェクト直下に Makefile と secrets/, srcs/ ディレクトリなどを作成
mkdir -p secrets
mkdir -p srcs
touch Makefile

# secretsディレクトリ内にパスワード用ファイルなどを空で用意 (必要なければ不要)
touch secrets/credentials.txt
touch secrets/db_password.txt
touch secrets/db_root_password.txt

# .gitignore を作って secrets 以下を除外 (必要に応じて調整)
cat <<EOF > .gitignore
# Secrets directory should be ignored
secrets/*
EOF

# srcs/ 配下に docker-compose.yml と .env を作成
touch srcs/docker-compose.yml
touch srcs/.env

# requirements フォルダを作成
mkdir -p srcs/requirements

# nginx のディレクトリ構成
mkdir -p srcs/requirements/nginx/{conf,tools}
touch srcs/requirements/nginx/Dockerfile
touch srcs/requirements/nginx/.dockerignore
# 必要なら設定ファイルも空で用意
# touch srcs/requirements/nginx/conf/default.conf

# entrypoint.sh (NGINX)
touch srcs/requirements/nginx/tools/entrypoint.sh
chmod +x srcs/requirements/nginx/tools/entrypoint.sh

# wordpress のディレクトリ構成
mkdir -p srcs/requirements/wordpress/{conf,tools}
touch srcs/requirements/wordpress/Dockerfile
touch srcs/requirements/wordpress/.dockerignore
# touch srcs/requirements/wordpress/conf/php-fpm.conf

# entrypoint.sh (WordPress)
touch srcs/requirements/wordpress/tools/entrypoint.sh
chmod +x srcs/requirements/wordpress/tools/entrypoint.sh

# mariadb のディレクトリ構成
mkdir -p srcs/requirements/mariadb/{conf,tools}
touch srcs/requirements/mariadb/Dockerfile
touch srcs/requirements/mariadb/.dockerignore
# touch srcs/requirements/mariadb/conf/my.cnf

# entrypoint.sh (MariaDB)
touch srcs/requirements/mariadb/tools/entrypoint.sh
chmod +x srcs/requirements/mariadb/tools/entrypoint.sh

echo "Inception project folders, files, and entrypoint.sh scripts have been created."
