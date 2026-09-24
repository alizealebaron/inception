# Avant-dernière version stable de Debian
FROM debian:bookworm
 
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 && \
    rm -rf /var/lib/apt/lists/*
 
# On copie le contenu statique (HTML/CSS/JS) dans l'image
COPY site/ /var/www/static-site/
 
WORKDIR /var/www/static-site

EXPOSE 8080

# python3 -m http.server tourne nativement au premier plan (PID 1),
# pas besoin de script wrapper ni de daemon : c'est déjà le comportement
# par défaut de cette commande.
CMD ["python3", "-m", "http.server", "8080", "--bind", "0.0.0.0"]