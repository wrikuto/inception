#!/bin/sh
#
# entrypoint.sh (WordPress)
# - WP設定ファイルの自動生成
# - WP-CLI で初回セットアップ (DB接続チェック, 管理者・一般ユーザ作成)
# - php-fpm をフォアグラウンドで起動

# 環境変数例 (docker-compose.yml や .env などから設定):
# WORDPRESS_DB_HOST, WORDPRESS_DB_NAME, WORDPRESS_DB_USER, WORDPRESS_DB_PASSWORD
# WP_ADMIN_USER, WP_ADMIN_PASSWORD, WP_USER, WP_USER_PASSWORD
# DOMAIN_NAME

WP_PATH="/var/www/html"
WP_CONFIG="${WP_PATH}/wp-config.php"

# php-fpmのPIDファイルを置くディレクトリ（存在しないとエラーになる場合がある）
mkdir -p /run/php

# ======================
# 1) WordPress設定ファイル生成
# ======================
if [ ! -f "${WP_CONFIG}" ]; then
  echo ">> wp-config.php not found. Creating..."

  cp ${WP_PATH}/wp-config-sample.php ${WP_CONFIG}

  sed -i "s/database_name_here/${WORDPRESS_DB_NAME}/" ${WP_CONFIG}
  sed -i "s/username_here/${WORDPRESS_DB_USER}/" ${WP_CONFIG}
  sed -i "s/password_here/${WORDPRESS_DB_PASSWORD}/" ${WP_CONFIG}
  sed -i "s/localhost/${WORDPRESS_DB_HOST}/"       ${WP_CONFIG}

  # 課題要件にある「2ユーザ(管理者・一般)」の作成は wp-cli で後ほど
  # ここでは wp-cli の salts 自動生成を行う場合がある:
  # 例: sed -i "s/put your unique phrase here/`curl -s https:\/\/api.wordpress.org\/secret-key\/1.1\/salt\/`/" ${WP_CONFIG}
fi

# ======================
# 2) WordPress 初回セットアップ (wp-cli)
# ======================
# wp-cli が無い場合はインストール (バージョンは適宜固定推奨)
if [ ! -f /usr/local/bin/wp ]; then
  echo ">> Installing wp-cli..."
  curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp
fi

# DB接続が可能になるまでリトライ (必要に応じてタイムアウト調整)
echo ">> Checking database connection..."
max_try=30
i=1
while ! mariadb -h"${WORDPRESS_DB_HOST}" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" -e "SELECT 1" &> /dev/null; do
  if [ $i -ge $max_try ]; then
    echo ">> Cannot connect to MariaDB after ${max_try} tries. Exiting."
    exit 1
  fi
  echo "   Waiting for MariaDB to be ready... ($i/$max_try)"
  i=$((i+1))
  sleep 2
done
echo ">> Database is ready."

# まだインストールが完了していない場合のみ実行 (wp_options テーブルを確認するなど)
if ! wp core is-installed --path="${WP_PATH}" --allow-root; then
  echo ">> Running wp core install..."
  wp core install \
    --url="${DOMAIN_NAME}" \
    --title="Inception Blog" \
    --admin_user="${WP_ADMIN_USER}" \
    --admin_password="${WP_ADMIN_PASSWORD}" \
    --admin_email="admin@example.com" \
    --path="${WP_PATH}" \
    --skip-email \
    --allow-root

  # 一般ユーザの作成
  if [ -n "${WP_USER}" ] && [ -n "${WP_USER_PASSWORD}" ]; then
    wp user create "${WP_USER}" "${WP_USER}@example.com" \
      --user_pass="${WP_USER_PASSWORD}" \
      --role=author \
      --path="${WP_PATH}" \
      --allow-root
    echo ">> Created WP user '${WP_USER}' with role 'author'."
  fi
else
  echo ">> WordPress is already installed. Skipping core install."
fi

# ======================
# 3) php-fpm フォアグラウンド起動
# ======================
echo ">> Starting php-fpm..."
exec php-fpm81 -F
