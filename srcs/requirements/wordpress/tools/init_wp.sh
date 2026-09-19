#!/bin/sh

until mysqladmin ping -h mariadb -u root -p${MYSQL_ROOT_PASSWORD} --silent; do
    echo "MariaDB not found"
    sleep 1
done

wp core download --allow-root --path=/var/www/wordpress

wp config create --dbname=${MYSQL_DATABASE} \
                 --dbuser=${MYSQL_USER} \
                 --dbpass=${MYSQL_PASSWORD} \
                 --dbhost=${MYSQL_HOSTNAME} \
                 --allow-root \
                 --path=/var/www/wordpress

wp core install --url=${DOMAIN_NAME} \
                --title=${WORDPRESS_TITLE} \
                --admin_user=${WORDPRESS_ADMIN_USER} \
                --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
                --admin_email=${WORDPRESS_ADMIN_EMAIL} \
                --allow-root \
                --path=/var/www/wordpress

wp user create ${USER2} \
               ${USER2_EMAIL} \
               --user_pass=${PASSWORD2} \
               --allow-root \
               --path=/var/www/wordpress \
               --role=author

exec php-fpm8.2 -F