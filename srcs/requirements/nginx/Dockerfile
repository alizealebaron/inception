# Récupération de l'avant dernière version stable
FROM debian:bookworm

# Installation des packages importants
RUN apt update
RUN apt install nginx -y
RUN apt install openssl -y

# Création d'un fichier de stockage de la clef SSL/TSL
RUN mkdir -p /etc/nginx/ssl

# Création d'un certificat et d'une clé TSL au démarrage
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=normandie/L=LH/O=42/OU=42/CN=alebaron.42.fr/UID=alebaron"

