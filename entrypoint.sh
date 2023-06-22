#!/bin/sh

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

# # set default values for godoo config file
# : ${CONFIG:='/etc/odoo/odoo.conf'}
# : ${ADDONS_PATH:='/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons'}
# : ${DATA_DIR:='/var/lib/odoo'}
# : ${LOG_LEVEL:='info'}
# : ${DB_MAXCONN:='64'}
# : ${LIMIT_TIME_CPU:='600'}
# : ${LIMIT_TIME_REAL:='1200'}
# : ${LIMIT_MEMORY_HARD:='2684354560'}
# : ${LIMIT_MEMORY_SOFT:='2147483648'}
# : ${DBFILTER:='.*'}

# # Export PATH
# export PWD=/usr/local/bin/godoo

# # Default values
# : ${URL:="http://localhost:8069"}
# : ${DATABASE:="odoo"}
# : ${USERNAME:="admin"}
# : ${PASSWORD:="admin"}

# install python packages
pip3 install pip --upgrade
pip3 install -r /etc/odoo/requirements.txt

# sed -i 's|raise werkzeug.exceptions.BadRequest(msg)|self.jsonrequest = {}|g' /usr/lib/python3/dist-packages/odoo/http.py

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
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

# # Parse command line options

# OPTARG=()
# function getopts() {
#     param="$4"
# }
# getopts "u" "$URL"
# getopts "d" "$DATABASE"
# getopts "n" "$USERNAME"
# getopts "p" "$PASSWORD"

# case "$4" in
#     -- | godoo)
#         exec godoo "$@"
#         ;;
#     -*)
#         exec godoo "$@"
#         ;;
#     *)
#         exec "$@"
# esac

# while getopts ":u:d:n:p:" opt; do
#     case $opt in
#         u)
#         URL=$OPTARG
#         ;;
#         d)
#         DATABASE=$OPTARG
#         ;;
#         n)
#         USERNAME=$OPTARG
#         ;;
#         p)
#         PASSWORD=$OPTARG
#         ;;
#         \?)
#         echo "Invalid option: -$OPTARG" >&2
#         exit 1
#         ;;
#         :)
#     esac
# done



exit 1
