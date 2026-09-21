# ************************************************************************** #
#       _  _     ____                     ,~~.                               #
#      | || |   |___  \             ,   (  ^ )>                              #
#      | || |_    __) |             )\~~'   (       _      _      _          #
#      |__   _|  / __/             (  .__)   )    >(.)__ <(^)__ =(o)__       #
#         |_|   |_____| .fr         \_.____,*      (___/  (___/  (___/       #
#                                                                            #
# ************************************************************************** #
# @name   : Makefile                                                         #
# @author : alebaron <alebaron@student.42lehavre.fr>                         #
#                                                                            #
# @creation : 2026/09/21 12:28:37 by alebaron                                #
# @update   : 2026/09/21 13:02:33 by alebaron                                #
# ************************************************************************** #

# -------------------------------------------------------------------------- #
#                                  Variables                                 #
# -------------------------------------------------------------------------- #

NAME		= inception
LOGIN		= alebaron
DATA_DIR	= /home/$(LOGIN)/data
COMPOSE		= docker compose -f srcs/docker-compose.yml

# -------------------------------------------------------------------------- #
#                             Règles de Makefile                             #
# -------------------------------------------------------------------------- #

all: $(NAME)

$(NAME): data_dirs
	@echo "Building and starting $(NAME)..."
	$(COMPOSE) up --build -d

data_dirs:
	@mkdir -p $(DATA_DIR)/db
	@mkdir -p $(DATA_DIR)/wordpress

up: $(NAME)

down:
	@echo "Stopping containers..."
	$(COMPOSE) down

stop:
	@echo "Stopping containers (without removing them)..."
	$(COMPOSE) stop

start:
	@echo "Starting existing containers..."
	$(COMPOSE) start

# Supprime les conteneurs et images du projet, garde les volumes/données
clean: down
	@echo "Removing images..."
	$(COMPOSE) down --rmi all

# Supprime tout, y compris les données persistantes sur l'hôte
# ATTENTION : destructif, supprime la base de données et le site WP
fclean: clean
	@echo "Removing persistent data in $(DATA_DIR)..."
	@sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all up down stop start clean fclean re data_dirs