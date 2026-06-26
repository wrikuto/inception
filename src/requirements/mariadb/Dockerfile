FROM alpine:3.20

LABEL maintainer="yourlogin@student.42tokyo.jp" \
      description="MariaDB 11 Alpine image built from source packages for 42 Inception"

# ── 必要パッケージをインストール ──────────────────────────────
RUN apk add --no-cache mariadb mariadb-client tzdata && \
    mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql

# ── エントリポイントスクリプト ──────────────────────────────
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306
VOLUME ["/var/lib/mysql"]

USER mysql

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mysqld_safe", "--datadir=/var/lib/mysql"]