#!/bin/sh
#
# entrypoint.sh (MariaDB)
# - 初回起動時にDBを初期化 (mysql_install_db)
# - root, カスタムユーザなどを設定
# - mysqldをフォアグラウンド起動

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo ">> Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null

    # MySQL起動用の一時プロセスでブートストラップ (ユーザ作成等)
    mysqld --user=mysql --bootstrap <<-EOSQL
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

    echo ">> Database '${MYSQL_DATABASE}' and user '${MYSQL_USER}' created."
else
    echo ">> MariaDB data directory already exists. Skipping init."
fi

# ポートを0.0.0.0で受け付けるように bind-addressを調整する場合、下記のようにする場合もある:
# exec mysqld --user=mysql --bind-address=0.0.0.0

echo ">> Starting mysqld..."
exec mysqld --user=mysql --bind-address=0.0.0.0
