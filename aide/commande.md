# Commandes

## Commandes docker utiles

### Construire un container

Build un container Docker:
```bash
docker build <lien_vers_dossier>
```

Build un container Docker avec un nom:
```bash
docker build -t <nom> <lien_vers_dossier>
```

### Afficher des informations

Afficher toutes les images actuellement téléchargées:
```bash
docker image ls
```

Afficher tous les containers actuellement lancés:
```bash
docker ps
```

Afficher tous les container lancés et stoppés:
```bash
docker ps -a
```

### Démarrer une image

Démarrer une image :
```bash
docker run <nom_image>
```

Démarrer une image et avoir accès à son terminal:
```bash
docker run -it <nom_image>

