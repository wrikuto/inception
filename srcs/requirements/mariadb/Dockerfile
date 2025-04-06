# **************************************************************************** #
#                           MariaDB Dockerfile (Alpine)                        #
# **************************************************************************** #

FROM alpine:3.17

# mariadb, mariadb-client をインストール
RUN apk update && apk add --no-cache \
    mariadb \
    mariadb-client \
    && rm -rf /var/cache/apk/*

# データベース用ディレクトリ
RUN mkdir -p /var/lib/mysql

# 起動スクリプトコピー
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ポート開放(コンテナ内部)
EXPOSE 3306

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "mysqld", "--bind-address=0.0.0.0" ]
