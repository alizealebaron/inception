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
```

### Arrêter / Détruire un container Docker

Arrêter un container docker: 
```bash
docker stop <nom_ou_id>
```

Détruire un container :
```bash
docker rm <nom_ou_id>
```

### Vérifier les ports ouverts d'un container

```bash
docker port <nom_container>
```

### Se connecter au container mariaDB en root

En tant que root:
``̀ bash
docker exec -it mariadb mysql -u root -p"$(cat secrets/db_root_password.txt)"
```

En tant que utilisateur wp:
```bash
docker exec -it mariadb mysql -u wp_user -p"$(cat secrets/db_password.txt)" wordpress
```

## MariaDB

Vérifier que wordpress existe bien dans la BDD:
```sql
-- Se positionner sur la bonne base
USE wordpress;

-- Lister toutes les tables : WordPress en crée normalement une douzaine
SHOW TABLES;

-- Compter les utilisateurs WordPress (doit afficher au moins 2 : admin + user)
SELECT ID, user_login, user_email FROM wp_users;
```