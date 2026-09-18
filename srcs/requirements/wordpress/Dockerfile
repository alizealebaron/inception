# Avant-dernière version stable de Debian
FROM debian:bookworm

# Installation des packages importants 
#   Note : rm -rf pour nettoyer le cache d'installation et éviter de prendre de la place pour rien
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      php-fpm php-cli php-mysql php-gd php-mbstring php-xml php-zip \
      curl ca-certificates mariadb-client && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /usr/local/bin/wp \
      https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp

# COPY conf/www.conf   /etc/php/8.2/fpm/pool.d/www.conf
# COPY tools/init.sh   /usr/local/bin/init.sh
# RUN chmod +x         /usr/local/bin/init.sh

# EXPOSE 9000
# CMD ["/usr/local/bin/init.sh"]