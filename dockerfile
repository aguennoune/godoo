FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    sudo \
    procps \
    procps-ng

# Create `/etc/sysctl.conf` file
RUN echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf


# Installation de Docker Compose
RUN apt-get update && apt-get install -y curl
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose



# Development stage
FROM golang:1.16.3-alpine3.13 as dev
WORKDIR /work
COPY . .

# Build stage
FROM golang:1.16.3-alpine3.13 as build
WORKDIR /godoo
COPY . .
RUN apk add --no-cache git
RUN go build -o /odoo/godoo

FROM debian:bullseye-slim as odoo

WORKDIR /godoo

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install latest PostgreSQL client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Install Odoo
ENV ODOO_VERSION 16.0
ARG ODOO_RELEASE=20230629
ARG ODOO_SHA=ef1a7436be87a897efa0d0b4a50a159d2ee3e1e3
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
# COPY ./etc/requirements.txt /etc/odoo/requirements.txt
# RUN pip3 install -r /etc/odoo/requirements.txt
COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

# Runtime stage
FROM tiangolo/uvicorn-gunicorn:python3.8-slim as runtime

# Set the working directory
WORKDIR /godoo/odoo

# Install Poetry 
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/etc/poetry python3 && \
    cd /usr/local/bin && \
    ln -s /etc/poetry/bin/poetry && \
    poetry config virtualenvs.create false

# Copy poetry.lock* in case it doesn't exist in the repo
COPY ./odoo/pyproject.toml ./odoo/poetry.lock* /odoo/

# Install dependencies
RUN poetry install --no-dev

# Copy the Godoo configuration file
COPY conf.toml /usr/local/bin/conf.toml
RUN chmod +x /usr/local/bin/conf.toml

# Copy the entrypoint and run scripts
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Copy the Godoo binary from the build stage
COPY --from=build /odoo/godoo /usr/local/bin/godoo
RUN chmod +x /usr/local/bin/godoo

# Set up the Godoo environment
ENV GODOO_CONFIG=/usr/local/bin/conf.toml

# Start the Godoo application
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo", "/run.sh"]