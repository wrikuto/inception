# **************************************************************************** #
#                      WordPress (PHP-FPM) Dockerfile (Alpine)                 #
# **************************************************************************** #

FROM alpine:3.17

# PHPや関連モジュールをインストール
RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-xml \
    php81-dom \
    php81-phar \
    php81-zip \
    php81-gd \
    php81-openssl \
    php81-mbstring \
    php81-tokenizer \
    php81-xmlreader \
    php81-xmlwriter \
    php81-simplexml \
    curl \
    tar \
    # 以下省略。必要に応じて追加
    && rm -rf /var/cache/apk/*

# WordPressのダウンロード等を行う
# ここでは Dockerビルド時に最新版(特定バージョンでもOK)をDLする例
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    rm latest.tar.gz && \
    # 展開したWordPressを /var/www/html に移動
    mkdir -p /var/www/html && \
    mv wordpress/* /var/www/html && \
    rm -rf wordpress

# PHP-FPM設定ファイルや pool設定を調整したい場合にコピーする
# COPY conf/www.conf /etc/php81/php-fpm.d/www.conf

# WordPress 初期設定やプラグイン導入などを行うエントリーポイントスクリプト
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# WordPressをPHP-FPMのフォアグラウンドモード(-F)で起動
ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "php-fpm81", "-F" ]
