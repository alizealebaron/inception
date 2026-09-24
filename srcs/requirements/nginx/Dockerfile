# Récupération de l'avant dernière version stable
FROM debian:bookworm

# Installation des packages importants
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Création d'un fichier de stockage de la clef SSL/TSL
RUN mkdir -p /etc/nginx/ssl

# Création d'un certificat et d'une clé TSL au démarrage
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=normandie/L=LH/O=42/OU=42/CN=alebaron.42.fr/UID=alebaron"

# Création d'un dossier pour la configuration de nginx
RUN mkdir -p /var/run/nginx

# Copier la configuration nginx dans l'image
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Mise en place du port
EXPOSE 443

# Démarrer nginx avec daemon off pour rester en arrière plan
CMD [ "nginx", "-g", "daemon off;" ]