# Run PostgrSQL docker image

```bash
$ docker run -it --rm --name postgres \
> -e POSTGRES_USER=odoo \
> -e POSTGRES_PASSWORD=odoo16@2023 \
> -e POSTGRES_DB=postgres \
> -e PGDATA="/data" \
> -v ${PWD}/pgdata:/data \
> -v ${PWD}/config:/config \
> -v ${PWD}/addons-extra:/mnt/addons-extra \
> -v ${PWD}/etc:/etc/odoo \
> -v ${PWD}/godoo:$HOME/go/bin/godoo \
> -p 5432:5432 \
> postgres:15.0 -c 'config_file=/config/postgresql.conf'
```

# Installing Odoo 16.0 with one command (Supports multiple Odoo instances on one server)

##### Quick Installation

Install docker and docker-compose yourself, then run the following to set up first Odoo instance @`localhost:8069` (default master password: `aguennoune.online`):

```bash
curl -s https://github.com/aguennoune/godoo/master/run.sh | sudo bash -s odoo-one 10016 20016
```
and/or run the following to set up another Odoo instance @`localhost:8070` (default master password: `aguennoune.online`):

```bash
curl -s https://github.com/aguennoune/godoo/master/run.sh | sudo bash -s odoo-two 11016 21016
```
Some arguments:
- First argument(odoo-one): Odoo deploy folder
- Second argument(10016): Odoo port
- Third argument(20016): live chat port

If `curl` is not installed, run `sudo apt-get install curl` (Debian/Ubuntu).

# Curl troubleshooting:

Useful GitHub Copilot Collected Suggestions: If it looks like you are trying to run a `curl` command to download a script from GitHub, but the output you received is not what you expected. The error message you may receive, could indicates that the output you received is not a valid shell script, but rather an HTML document, as i encountered seemlessly.

This could be caused by a few different things, such as an incorrect URL or a network issue. To troubleshoot this issue, you can try the following:

1. Double-check the URL you are using to download the script. Make sure it is correct and that it points to a raw file on GitHub.

2. Check your network connection to ensure that you are able to connect to GitHub. You can try pinging GitHub to see if you are able to reach it.

3. If you are still having issues, you can try downloading the script manually from GitHub and running it locally.

Here are some possible commands that might be helpful:

- Ping: `ping github.com`
- Download script: `curl -O https://raw.githubusercontent.com/aguennoune/godoo/master/run.sh`
- Run script: `sudo bash run.sh odoo-one 10016 20016`

Also, troubleshoot the following issue:

GitHub Copilot: It looks like you are encountering a few different issues. Here are some possible solutions:

1. The error message `Could not open requirements file: [Errno 2] No such file or directory: 'odoo-one/requirements.txt'` indicates that the `requirements.txt` file is missing. Make sure that the file exists in the `odoo-one` directory and that the path is correct.

2. The error message `Error response from daemon: pull access denied for godoo/godoo, repository does not exist or may require 'docker login': denied: requested access to the resource is denied` indicates that you do not have permission to access the `godoo/godoo` Docker repository. Make sure that you have the correct credentials and that you are logged in to Docker.

3. The message `Started Odoo @ http://localhost:10016 | Master Password: aguennoune.online | Live chat port: 20016` indicates that the Odoo server has started successfully. You can now access the server by navigating to `http://localhost:10016` in your web browser.

4. The lines `fs.inotify.max_user_watches = 524288` indicate that the `max_user_watches` value needs to be increased. You can do this by running the following command in your terminal: `sudo sysctl -w fs.inotify.max_user_watches=524288`.

Here are some possible commands that might be helpful:

- `docker login` command: https://docs.docker.com/engine/reference/commandline/login/
- `docker pull` command: https://docs.docker.com/engine/reference/commandline/pull/
- `sudo sysctl` command: https://linux.die.net/man/8/sysctl

##### Usage:

Start the container:

```bash
docker-compose up
```
Then open `localhost:8069` in your browser to access Odoo 16.0.

- If you get any permission issues, change the folder permission to make sure that the container is able to access the directory:

```bash
sudo chmod -R 777 addons
sudo chmod -R 777 etc
sudo chmod -R 777 pgdata
sudo chmod -R 777 config
sudo chmod -R 777 godoo
```

##### Specifying Custom Configuration:

If we run on Linux, we need to ensure that the `postgres` user which has a user ID of `999` has read and write access to the `pgdata` directory. Also, by default, should have access to the configuration files in the `config` directory.

```bash
sudo chown 999:999 pgdata
sudo chown 999:999 config/postgresql.conf
sudo chown 999:999 config/pg_hba.conf
sudo chown 999:999 config/pg_ident.conf
sudo chown 999:999 etc/odoo.conf
sudo chown 999:999 godoo
```

```{Note}
The `PGDATA` variable tells PostgreSQL where our data directory is. Similarly, we've presumely learnt that our configuration file also has `data_directory` which tells PostgreSQL the same.
However, the latter is only read by PostgreSQL after initialization has occured.
PostgreSQL's initialization phase sets up directory permissions on the data directory.
If we leave out `PGDATA`, then we will get errors that the data directory is invalid.
Hence `PGDATA` is required for PostgreSQL to start. That is why it is important here.   
```

If you want to start the server with a different port, change `10016` to another value in `docker-compose.yml` inside the parent dir:

```yaml
ports:
 - "10016:8069"
```

To run Odoo container in detached mode (be able to close terminal without stopping Odoo):

```bash
docker-compose up -d
```

To Use a restart policy, i.e. configure the restart policy for a container, change the value related to restart key in docker-compose.yml file to one of the following:

```ini
no = Do not automatically restart the container. (the default)
on-failure[:max-retries] = Restart the container if it exits due to an error, which manifests as a non-zero exit code. Optionally, limit the number of times the Docker daemon attempts to restart the container using the :max-retries option.
always = Always restart the container if it stops. If it is manually stopped, it is restarted only when Docker daemon restarts or the container itself is manually restarted. (See the second bullet listed in restart policy details)
unless-stopped = Similar to always, except that when the container is stopped (manually or otherwise), it is not restarted even after Docker daemon restarts.
 restart: always             # run as a service
```

To increase maximum number of files watching from 8192 (default) to 524288. In order to avoid error when we run multiple Odoo instances. This is an optional step. These commands are for Ubuntu user:

```bash
$ if grep -qF "fs.inotify.max_user_watches" /etc/sysctl.conf; then echo $(grep -F "fs.inotify.max_user_watches" /etc/sysctl.conf); else echo "fs.inotify.max_user_watches = 524288" | sudo tee -a /etc/sysctl.conf; fi
$ sudo sysctl -p    # apply new config immediately
```

##### Custom addons
The addons/ folder contains custom addons. Just put your custom addons if you have any.

##### Odoo configuration & log

- To change Odoo configuration, edit file: `etc/odoo.conf`.
- Log file: `etc/odoo-server.log`
- Default database password (admin_passwd) is `aguennoune.online`, please change it @ `etc/odoo.conf#L60`

##### Odoo container management
Run Odoo:

```bash
docker-compose up -d
```

Restart Odoo:

```bash
docker-compose restart
```

Stop Odoo:

```bash
docker-compose down
```

##### Live chat
In docker-compose.yml#L21, we exposed port 20016 for live-chat on host.

Configuring nginx to activate live chat feature (in production):

```nginx	
#...
server {
    #...
    location /longpolling/ {
        proxy_pass http://0.0.0.0:20016/longpolling/;
    }
    #...
}
#...
```

##### docker-compose.yml
odoo:16.0
postgres:15


##### Odoo 16.0 screenshots after successful installation.








Thanks to @minhng92/odoo-16-docker-compose
Thanks to @llonchj/godoo
Thanks to @marceldempers/docker-development-youtube-series