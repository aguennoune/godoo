#!/bin/sh

# Set environment variables
export DESTINATION=$1
export PORT=$2
export CHAT=$3
export PWD=$4

# Clone Odoo directory
git clone --depth=1 https://github.com/aguennoune/godoo $DESTINATION
rm -rf $DESTINATION/.git

# Set permissions
mkdir -p $DESTINATION/pgdata
chmod -R 777 $DESTINATION
chmod -R 777 $PWD

# Install dependencies
apt-get update
apt-get install -y git python3-pip
pip3 install -r $DESTINATION/requirements.txt

# Configure container
if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf); else echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf; fi
sysctl -p
sed -i 's/10016/'$PORT'/g' $DESTINATION/docker-compose.yml
sed -i 's/20016/'$CHAT'/g' $DESTINATION/docker-compose.yml

# Run Odoo
docker-compose -f $DESTINATION/docker-compose.yml up -d

echo 'Started Odoo @ http://localhost:'$PORT' | Master Password: aguennoune.online | Live chat port: '$CHAT