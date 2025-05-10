#!/bin/sh
set -eu

# ── 初回起動チェック ──────────────────────────────
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "[MariaDB] 初回起動: データベースを初期化します…"
  mysql_install_db --user=mysql --rpm --datadir=/var/lib/mysql

  # 一時的に mysqld を起動（ネットワーク無効化）
  mysqld_safe --datadir=/var/lib/mysql --skip-networking &
  pid="$!"
  until mysqladmin ping --silent; do sleep 1; done

  # ── パスワード & 権限設定 ───────────────────────
  MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-rootpass}"
  mysql -uroot <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test;
    FLUSH PRIVILEGES;
EOSQL

  # ── ユーザー & DB 作成 ───────────────────────────
  if [ -n "${MYSQL_DATABASE:-}" ]; then
    mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" \
      -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  fi

  if [ -n "${MYSQL_USER:-}" ] && [ -n "${MYSQL_PASSWORD:-}" ]; then
    mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
      CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
      GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE:-*}\`.* TO '${MYSQL_USER}'@'%';
      FLUSH PRIVILEGES;
EOSQL
  fi

  # ── 一時 mysqld を停止 ──────────────────────────
  kill "$pid"
  wait "$pid"
fi

# ── 本番 mysqld_safe 起動 (foreground) ────────────
exec "$@"