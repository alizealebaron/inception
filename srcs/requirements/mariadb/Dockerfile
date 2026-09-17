# Récupération de l'avant dernière version stable
FROM debian:bookworm

# Installation des packages importants 
#   Note : rm -rf pour nettoyer le cache d'installation et éviter de prendre de la place pour rien
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install mariadb-server -y && \
    rm -rf /var/lib/apt/lists/*

# Configuration custom : on remplace la conf par défaut
COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf

# Script d'initialisation / entrypoint en lui donnant les droits pour fonctionner
#   Note : Les dossiers /var/lib/mysql exite déjà, mais la commande permet de s'assurer qu'il soit bien là tout de même
#   Note : Changement de propriétaire pour mysql afin que le script fonctionne (il utilisera les perms mysql)

COPY tools/init_db.sh /usr/local/bin/init_db.sh
RUN chmod +x /usr/local/bin/init_db.sh && \
    mkdir -p /var/lib/mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld

# On ajout un port d'écoute au réseau interne de docker
EXPOSE 3306

# On assure le fait que le script démarrera à chaque démarrage de l'image mariadb
ENTRYPOINT ["/usr/local/bin/init_db.sh"]