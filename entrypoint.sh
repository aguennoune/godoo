#!/bin/bash

set -e

# # Configure sysctl
# /sbin/sysctl -w net.core.somaxconn=65535
# /sbin/sysctl -w net.ipv4.tcp_max_syn_backlog=65535
# /sbin/sysctl -w net.ipv4.ip_forward=1

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user, and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo16@2023'}}}

# set default values for godoo config file
: ${CONFIG:='/etc/odoo.conf'}
: ${ADDONS_PATH:='/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons'}
: ${DATA_DIR:='/var/lib/odoo'}
: ${LOG_LEVEL:='info'}
: ${DB_MAXCONN:='64'}
: ${LIMIT_TIME_CPU:='600'}
: ${LIMIT_TIME_REAL:='1200'}
: ${LIMIT_MEMORY_HARD:='2684354560'}
: ${LIMIT_MEMORY_SOFT:='2147483648'}
: ${DBFILTER:='.*'}

# Export PATH
export PWD=/usr/local/bin/godoo

# Default values
: ${URL:="http://localhost:8069"}
: ${DATABASE:="odoo"}
: ${USERNAME:="admin"}
: ${PASSWORD:="admin"}

# Install python packages
pip3 install pip --upgrade
pip3 install -r requirements.txt

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then       
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

# Activate virtual environment
source "$(poetry env info --path)/bin/activate"

# Start odoo
exec odoo "$@"

# Export GODOO_CONFIG variable
export GODOO_CONFIG=/usr/local/bin/conf.toml

# Load completions for godoo
source <(godoo completion bash)

# Use GODOO_CONFIG variable as an argument for godoo
exec godoo -u $URL -d $DATABASE -n $USERNAME -p $PASSWORD "$@"

exit 1
