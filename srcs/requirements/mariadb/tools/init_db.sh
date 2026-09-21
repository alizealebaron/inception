#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Si la base "wordpress" n'existe pas encore, c'est le tout premier démarrage : on fait l'initialisation complète une seule fois.
# Permet de gérer les cas de redémarrage comme demandé dans le sujet
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then

    mysqld_safe --datadir=/var/lib/mysql &

    # On attend que le serveur soit prêt avant d'envoyer des requêtes
    until mysqladmin ping --silent; do
        sleep 1
    done

    mysql -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"

    mysqladmin -u root -p"${DB_ROOT_PASSWORD}" shutdown
fi

# mysqld devient le PID 1, tourne au premier plan, reçoit les signaux
exec mysqld --user=mysql