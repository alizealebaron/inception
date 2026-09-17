# Récupération de l'avant dernière version stable
FROM debian:bookworm

# Installation des packages importants
RUN apt update -y
RUN apt upgrade -y
RUN apt install nginx -y
RUN apt install openssl -y

# Création d'un fichier de stockage de la clef SSL/TSL
RUN mkdir -p /etc/nginx/ssl

# Création d'un certificat et d'une clé TSL au démarrage
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=normandie/L=LH/O=42/OU=42/CN=alebaron.42.fr/UID=alebaron"

# Création d'un dossier pour la configuration de nginx
RUN mkdir -p /var/run/nginx

# Copier la configuration nginx dans l'image
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Configuration pour l'internet
RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

# Démarrer nginx avec daemon off pour rester en arrière plan
CMD [ "nginx", "-g", "daemon off;" ]