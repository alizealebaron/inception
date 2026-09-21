# Developer Documentation

This document explains how to set up, build, and maintain the Inception project as a developer.

## 1. Prerequisites

- Docker Engine and the Docker Compose plugin installed
  (`docker compose version` should work).
- `make`.
- Root/sudo access (to write to `/etc/hosts` and to `/home/<login>/data`).

## 2. Project structure

```
.
├── Makefile
├── README.md / USER_DOC.md / DEV_DOC.md
├── secrets/                     # plaintext secrets, gitignored
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env                     # non-sensitive configuration
    └── requirements/
        ├── mariadb/{Dockerfile, conf/, tools/}
        ├── nginx/{Dockerfile, conf/, tools/}
        └── wordpress/{Dockerfile, conf/, tools/}
```

Each service directory contains:
- `Dockerfile` - builds the service's image.
- `conf/` - configuration files copied into the image at build time.
- `tools/` - the entrypoint script run at container startup.

## 3. Setting up the environment from scratch

1. Clone the repository.
2. Adjust configuration for your own login:
   - `srcs/.env`: set `DOMAIN_NAME=<login>.42.fr` and the WordPress admin/user settings.
   - `srcs/docker-compose.yml`: update the `device:` paths under `volumes.db_volume` / `volumes.wp_volume` to `/home/<login>/data/db` and `/home/<login>/data/wordpress`.
   - `Makefile`: set `LOGIN = <your_login>` to match the same path.
3. Fill in real passwords in `secrets/db_password.txt`, `secrets/db_root_password.txt` and `secrets/credentials.txt` (format `KEY=VALUE` for the latter, see USER_DOC.md). These files are gitignored and must never be committed.
4. Add the domain to `/etc/hosts`:
   ```
   127.0.0.1    <login>.42.fr
   ```

## 4. Building and launching the project

The `Makefile` wraps `docker compose` and takes care of creating the host directories required by the named volumes before starting anything (Docker does not create bind-mounted target directories automatically):

```bash
make          # create data dirs, build images, start containers (detached)
make down     # stop and remove containers, keep data
make clean    # down + remove built images
make fclean   # clean + delete persistent data under /home/<login>/data
make re       # fclean + make
```

Equivalent raw command, if you need to run Compose directly (e.g. to see logs live without `-d`):

```bash
docker compose -f srcs/docker-compose.yml up --build
```

## 5. Managing containers and volumes

```bash
# Container status / logs
docker ps -a
docker logs <container_name>
docker exec -it <container_name> bash    # shell into a running container

# Volumes: list, inspect (see the bind driver_opts in "Options")
docker volume ls
docker volume inspect srcs_db_volume
docker volume inspect srcs_wp_volume

# Network
docker network ls
docker network inspect srcs_inception_network
```

To validate the compose file without starting anything:

```bash
docker compose -f srcs/docker-compose.yml config
```

## 6. Where project data is stored and how it persists

The database and WordPress files are stored in two **named Docker volumes** (`db_volume`, `wp_volume`), each configured with the `local` driver's bind `driver_opts` so that, in addition to being real Docker-managed volumes (visible in `docker volume ls`), their actual data lives on the host filesystem at:

- `/home/<login>/data/db` - MariaDB's datadir (`/var/lib/mysql` inside the `mariadb` container)
- `/home/<login>/data/wordpress` - WordPress' files (`/var/www/wordpress` inside both the `wordpress` and `nginx` containers, which share this same volume so nginx can serve the files WordPress/php-fpm writes)

This data **survives** `make down`, `make clean`, and container restarts or crashes (thanks to `restart: always` in the compose file). It is only deleted by `make fclean`, which explicitly removes `/home/<login>/data`.

Both `mariadb` and `wordpress` entrypoint scripts (`init_db.sh`, `init_wp.sh`) check whether their respective data already exists (`/var/lib/mysql/<db_name>`, `/var/www/wordpress/wp-config.php`) before running their first-boot initialization logic, so that a container restart never re-runs the install/setup steps against already-initialized data.

## 7. Debugging tips

- A `502 Bad Gateway` from nginx usually means php-fpm isn't reachable on `wordpress:9000` - check `docker logs wordpress` for a crash during startup, and confirm php-fpm's pool config (`listen = 9000`, i.e. all interfaces, not `127.0.0.1:9000`).
- A blank/empty site or "directory index... is forbidden" from nginx usually means the `wp_volume` is empty - check that WordPress was actually downloaded/installed into `/var/www/wordpress` (the working directory matters here: the Dockerfile sets `WORKDIR /var/www/wordpress` precisely so `wp-cli` operates in the right place).
- A MariaDB authentication error (`Host '...' is not allowed to connect`) usually means the application database user was never created - check `init_db.sh`'s environment variable names against what's actually defined in `.env`, and remember that a stale/partially-initialized `db_volume` will make the script skip re-creating the user on the next boot (see the first-boot check in section 6).
