# Avant-dernière version stable de Debian
FROM debian:bookworm
 
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 && \
    rm -rf /var/lib/apt/lists/*
 
# On copie le contenu statique (HTML/CSS/JS) dans l'image
COPY site/ /var/www/static-site/

# Essentiel pour afficher la bonne page html
WORKDIR /var/www/static-site

# On met en écoute le port 8080 à l'intérieur de docker, il sera lié plus tard
EXPOSE 8080

# python3 -m http.server tourne nativement au premier plan (PID 1),
# pas besoin de daemon : c'est déjà le comportement par défaut de cette commande.
ENTRYPOINT ["python3", "-m", "http.server", "8080", "--bind", "0.0.0.0"]