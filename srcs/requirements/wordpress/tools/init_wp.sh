#!/bin/bash

cd /var/www/wordpress
set -e

# Récupération de données

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(grep WP_ADMIN_PASSWORD /run/secrets/credentials | cut -d '=' -f2)
WP_USER_PASSWORD=$(grep WP_USER_PASSWORD /run/secrets/credentials | cut -d '=' -f2)
WP_ADMIN_USER=$(grep WP_ADMIN_USER /run/secrets/wp_user | cut -d '=' -f2)
WP_ADMIN_EMAIL=$(grep WP_ADMIN_EMAIL /run/secrets/wp_user | cut -d '=' -f2)
WP_USER=$(grep WP_USER /run/secrets/wp_user | cut -d '=' -f2)
WP_USER_EMAIL=$(grep WP_USER_EMAIL /run/secrets/wp_user | cut -d '=' -f2)

# On attend que MariaDB soit prêt à accepter des connexions.
#    Sans cette attente active, l'installation WordPress échouerait.

echo "[init_wp] En attente de MariaDB..."
until mysqladmin ping -h "mariadb" --silent; do
    sleep 1
done
echo "[init_wp] MariaDB est prêt."

# Installation, uniquement si WordPress n'est pas déjà installé
#   (cas d'un redémarrage de conteneur : le volume persiste déjà tout)
if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    echo "[init_wp] Téléchargement du cœur de WordPress..."
    wp core download --allow-root

    echo "[init_wp] Génération de wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root

    echo "[init_wp] Installation de WordPress..."
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    echo "[init_wp] Création du second utilisateur (non-admin)..."
    wp user create \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    chown -R www-data:www-data /var/www/wordpress
fi

echo "[init_wp] Démarrage de php-fpm en foreground..."
exec php-fpm8.2 -F