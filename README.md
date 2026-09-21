<p align="center">
  <img src="https://github.com/alizealebaron/alizealebaron/blob/main/assets/inception.png" width="120"/>
</p>
<h3 align="center">
  <em>One container is not enough.</em>
</h3>

---

<div align="center">
  <p>
      <!-- <img src="https://img.shields.io/badge/score-100%20%2F%20100-success?style=for-the-badge" /> -->
      <img src="https://img.shields.io/github/last-commit/alizealebaron/inception?style=for-the-badge" />
  </p>
</div>

## ⚠️ Avant propos

- **Portfolio :** Ce répertoire se concentre sur un seul sujet. Vous pouvez retrouver tous mes projets sur mon [profil](https://github.com/alizealebaron).
- **Sujet :** Conformément aux règles de 42, vous ne trouverez pas le sujet de l'exercice dans ce répertoire.
- **État du projet:** Le code est exactement le même que lorsqu'il a été validé. Il ne sera pas mis à jour même s'il contient des erreurs.
- **Aide & Licence :** Ce répertoire est principalement là pour vous aider à faire votre propre code. Évitez de copier / coller sans comprendre le code.

## 🦆 Status

**Commencé le :** 15/07/2026

**Rendu le :** Non rendu.

## Introduction à Inception

Ce projet a pour objectif d'approfondir nos connaissances en administration système grâce à l'utilisation de Docker. Au cours de ce projet, nous allons virtualiser plusieurs images Docker en les créant sur une nouvelle machine virtuelle personnelle. Ce guide à pour objectif de vous guider pas à pas vers la compréhension et la réalisation de ce projet.

## Sommaire

1. [Introduction à Docker](guide/introduction_docker.md)
2. [Prérequis pour Inception (VM, Docker)](guide/installation.md)

## Description

Inception est un projet de système d'administration dont l'objectif est de mettre en place une petite infrastructure web, proche d'un environnement de production, entièrement avec **Docker**, en utilisant **Docker Compose** pour orchestrer plusieurs conteneurs, chacun exécutant un seul service, et communiquant entre eux via un réseau Docker dédié.

L'infrastructure déployée est un classique **LEMP** (Linux, nginx, MariaDB, PHP) servant un site **WordPress** :

- **nginx** — le point d'entrée unique de l'infrastructure, exposé uniquement sur le port 443, servant du HTTPS (TLSv1.2/TLSv1.3) et redirigeant les requêtes PHP vers le conteneur WordPress via FastCGI.
- **WordPress + php-fpm** — le cœur WordPress et le processus PHP-FPM qui traite les requêtes PHP dynamiques, installé et configuré via `wp-cli` au démarrage du conteneur.
- **MariaDB** — le moteur de base de données stockant les données de WordPress, initialisé au premier démarrage avec une base dédiée et un utilisateur applicatif.

Chaque service est construit à partir de son **propre Dockerfile**, basé sur `debian:bookworm` (l'avant-dernière version stable de Debian), et aucune image toute faite issue de Docker Hub n'est utilisée en dehors de l'image de base Debian elle-même.

## Instructions

Voir [`DEV_DOC.md`](./DEV_DOC.md) pour les instructions complètes de build et de lancement, et [`USER_DOC.md`](./USER_DOC.md) pour savoir comment utiliser le site une fois lancé. En résumé :

```bash
git clone <repo_url> inception
cd inception
make
```

Puis rends-toi sur `https://alebaron.42.fr` (après avoir configuré `/etc/hosts`, voir USER_DOC.md).

### Principaux choix de conception

**Machine Virtuelle vs Docker**

Une VM classique virtualise un système d'exploitation entier (son propre noyau, ses pilotes, son init) au-dessus d'un hyperviseur, ce qui la rend lourde à démarrer et difficile à reproduire à l'identique. Les conteneurs Docker, eux, partagent le noyau de la machine hôte et n'isolent que l'espace utilisateur (processus, système de fichiers, réseau), ce qui les rend bien plus légers, rapides à démarrer et reproductibles — idéal pour séparer proprement nginx, PHP et la base de données en trois unités indépendantes, jetables et facilement reconstructibles. Ce projet tourne **à l'intérieur** d'une VM uniquement parce que le sujet de l'école l'impose, mais Docker en lui-même n'a pas besoin d'une VM pour fonctionner.

**Secrets vs Variables d'environnement**

Les variables d'environnement (`.env`, `env_file`) sont pratiques pour de la configuration non sensible (nom de domaine, nom de base de données, noms d'utilisateurs), mais elles restent visibles via `docker inspect`, dans l'environnement du conteneur, et peuvent facilement se retrouver dans des logs ou des rapports de crash. Les **secrets** Docker, eux, sont montés sous forme de fichiers en lecture seule dans `/run/secrets/<nom>`, uniquement pour les conteneurs qui les déclarent explicitement, et ne sont jamais persistés dans les layers de l'image ni exposés via `docker inspect`. Ce projet utilise donc `.env` uniquement pour les
réglages non sensibles, et des secrets Docker (`db_password.txt`, `db_root_password.txt`, `credentials.txt`) pour tous les mots de passe.

**Réseau Docker vs Réseau Host**

`network: host` fait partager directement au conteneur la pile réseau de la machine hôte — aucune isolation, pas de résolution DNS interne, et une surface d'attaque bien plus grande (chaque port du conteneur devient un port de l'hôte). Un réseau Docker dédié de type **bridge**, comme utilisé ici (`inception_network`), isole les conteneurs du réseau de l'hôte, n'expose que les ports explicitement publiés (443 pour nginx), et fournit une résolution DNS automatique entre services par leur nom (par exemple `wordpress` se résout vers l'IP du conteneur WordPress) — c'est ce qui permet à nginx de joindre `wordpress:9000` et à WordPress de joindre `mariadb:3306`.

**Volumes Docker vs Bind Mounts**

Un bind mount fait correspondre directement un chemin de l'hôte à l'intérieur d'un conteneur, sans aucune abstraction : Docker ne le gère pas, et les permissions/chemins sont fortement couplés à l'organisation du système de fichiers de l'hôte. Un **volume nommé**, lui, est un objet géré par Docker avec son propre cycle de vie (créable, listable, inspectable, supprimable indépendamment de tout conteneur), ce qui est plus sûr, plus portable, et constitue la méthode officiellement recommandée pour persister les données d'un conteneur. Ce projet utilise des volumes nommés pour la base de données et les fichiers WordPress, configurés avec les `driver_opts` de type bind du driver `local`, de sorte que leurs données se retrouvent physiquement stockées sous `/home/alebaron/data` comme l'exige le sujet, tout en restant de véritables volumes gérés par Docker plutôt que de simples bind mounts.

## Ressources

### Installation 

- [Comment installer Ubuntu dans Virtualbox](https://www.numetopia.fr/comment-installer-ubuntu-dans-virtualbox/)
- [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

### Introduction à Docker

#### Blog

- [Qu’est-ce que Docker ? Notre guide complet](https://about.gitlab.com/fr-fr/blog/what-is-docker-comprehensive-guide/)
- [Qu’est-ce que Docker ?](https://www.ibm.com/fr-fr/think/topics/docker#:~:text=Docker%20est%20une%20plateforme%20open,jour%20et%20g%C3%A9rer%20des%20conteneurs.)
- [Docker : qu’est-ce que c’est et comment l’utiliser ?](https://liora.io/docker-guide-complet)
- [Image Docker vs conteneur : explication des principales différences](https://www.hostinger.com/fr/tutoriels/image-docker-vs-conteneur/)
- [Commandes Docker essentielles : le guide CLI complet](https://blog.stephane-robert.info/docs/conteneurs/moteurs-conteneurs/docker/cli/)

### Configurer les Dockerfile

- [Inception Tips](https://inception.cluzet.fr/)
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)

### Documentation

- [Documentation Docker](https://docs.docker.com/)
- [Référence du fichier Docker Compose](https://docs.docker.com/compose/compose-file/)
- [Documentation WordPress CLI (wp-cli)](https://wp-cli.org/)
- [Documentation NGINX](https://nginx.org/en/docs/)
- [Documentation MariaDB](https://mariadb.com/kb/en/documentation/)

### Autres Inception

- [Inception d'Azedineouhadou](https://github.com/azedineouhadou/inception-42#description)
- [Inception de mitsukio-o](https://github.com/mitsukio-o/Inception/tree/master/srcs/requirements)

### Utilisation de l’IA

L’intelligence artificielle a été utilisée de manière ciblée pour :

- aider à la reformulation, à la structuration et à la traduction du README et de la documentation;
- relecture des fichiers de configuration et Dockerfile pour vérifier la correspondance avec le sujet;
- aider à la correction de certains bugs rencontrés.

---

**Dernière modification**: 21 Septembre 2026\
**Contact :** alebaron@student.42lehavre.fr
