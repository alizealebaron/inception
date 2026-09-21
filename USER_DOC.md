# User Documentation

This document is for anyone who wants to **use** the Inception stack: browse the website, log into the admin panel, or check that everything is running - no development knowledge required.

## 1. What services does this stack provide?

The project runs three containers working together:

| Service    | What it does                                             |
|------------|-----------------------------------------------------------|
| `nginx`    | The website's HTTPS entrypoint (port 443)                 |
| `wordpress`| Runs the WordPress site and processes PHP (not directly reachable from outside) |
| `mariadb`  | Stores all of WordPress' data (posts, users, settings...) |

You only ever interact with the website through **nginx**, on port `443`, in HTTPS. The other two containers are internal and not reachable directly from your browser.

## 2. Starting and stopping the project

From the project's root directory:

```bash
# Build the images (first time only) and start everything
make

# Stop the containers (keeps your data)
make down

# Stop the containers without removing them (quick pause)
make stop

# Restart previously stopped containers
make start

# Remove containers + images, but KEEP your data
make clean

# Remove EVERYTHING, including your WordPress site and database (destructive)
make fclean

# Rebuild everything from scratch
make re
```

Check that the three containers are running with:

```bash
docker ps
```

You should see `nginx`, `wordpress` and `mariadb`, all with a status of
`Up` (not `Restarting`).

## 3. Accessing the website and the admin panel

Before your first visit, make sure your machine resolves the project's domain name. Add this line to `/etc/hosts` (as root):

```
127.0.0.1    alebaron.42.fr
```

(If you're browsing from a machine other than the one running Docker, replace `127.0.0.1` with that machine's IP address instead.)

Then, in your browser:

- **Website**: `https://alebaron.42.fr`
- **Admin panel**: `https://alebaron.42.fr/wp-admin`

Your browser will show a security warning ("Your connection is not private") the first time you visit - this is expected, because the site uses a **self-signed** TLS certificate (there is no public certificate authority involved, as this is a local/school project). Click "Advanced" → "Proceed anyway" (wording varies by browser).

## 4. Locating and managing credentials

- Non-sensitive settings (domain name, database name, WordPress title...) live in `srcs/.env`.
- Passwords live as plain text files inside the `secrets/` folder at the project's root: - `secrets/db_root_password.txt` - MariaDB root password - `secrets/db_password.txt` - password of the WordPress database user - `secrets/credentials.txt` - WordPress admin and regular-user passwords   (format `KEY=VALUE`, one per line)

The WordPress **admin username** is defined by `WP_ADMIN_USER` in `srcs/.env`, and its password is the `WP_ADMIN_PASSWORD` line in `secrets/credentials.txt`. A second, non-admin WordPress user is also created, using `WP_USER` / `WP_USER_EMAIL` from `.env` and `WP_USER_PASSWORD` from `secrets/credentials.txt`.

⚠️ These files are intentionally excluded from Git (see `.gitignore`) - never commit them.

## 5. Checking that the services are running correctly

```bash
# All three containers should show "Up", not "Restarting"
docker ps -a

# Look for errors in any specific service's logs
docker logs nginx
docker logs wordpress
docker logs mariadb
```

If the website doesn't load:
1. Confirm all three containers are `Up`.
2. Check `docker logs nginx` for connection errors to `wordpress:9000`.
3. Check `docker logs wordpress` to confirm WordPress finished installing
   and `php-fpm` started without errors.
4. Check `docker logs mariadb` to confirm the database initialized
   correctly on first boot.

See [`DEV_DOC.md`](./DEV_DOC.md) for a more technical breakdown of the stack if you need to go further.
