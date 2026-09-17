# Récupération de l'avant dernière version stable
FROM debian:bookworm

# Installation des packages importants
RUN apt update -y
RUN apt upgrade -y
RUN apt-get install mariadb-server -y

# Copier le fichier de configuration
COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf