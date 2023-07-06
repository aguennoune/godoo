FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    git \
    python3-pip \
    curl

# Create `/etc/sysctl.conf` file
RUN echo "fs.inotify.max_user_watches = 524288" >> /etc/sysctl.conf

# Development stage
FROM golang:1.16.3-alpine3.13 as dev
WORKDIR /godoo
COPY . .

# Build stage
FROM golang:1.16.3-alpine3.13 as build
WORKDIR /godoo
COPY . .
RUN apk add --no-cache git
RUN go build -o /usr/local/bin/godoo

FROM alpine:latest

WORKDIR /godoo

# Install latest PostgreSQL client
RUN apk update && apk add --no-cache postgresql-client

# Runtime stage
FROM tiangolo/uvicorn-gunicorn:python3.8-slim as runtime

# Copy the Godoo binary from the build stage
COPY --from=build /godoo/godoo /usr/local/bin/godoo
RUN chmod +x /usr/local/bin/godoo

ENV PATH="${PATH}:/root/.local/bin" 

# Set up the Godoo environment
ENV GODOO_CONFIG=/usr/local/bin/conf.toml

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl

# Set the working directory
WORKDIR /godoo/

# Install Poetry 
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/opt/poetry python3 && \
    cd /usr/local/bin && \
    ln -s /opt/poetry/bin/poetry && \
    poetry config virtualenvs.create false

# Set up Poetry environment variables
ENV PATH="${PATH}:/root/.poetry/bin"
ENV PYTHONPATH="${PYTHONPATH}:/root/.poetry/lib"

# Copy the project code into the container
COPY . .

# Copy poetry.lock* in case it doesn't exist in the repo
COPY pyproject.toml /

ARG GODOO_CONFIG=false
RUN if [ "$GODOO_CONFIG" = "true" ] ; then \
    # Install project dependencies
    poetry install --no-root ; \
    fi

ENV PYTHONPATH=/godoo

# Copy the Godoo configuration file
COPY conf.toml /usr/local/bin/conf.toml
RUN chmod +x /usr/local/bin/conf.toml

# Copy the entrypoint and run scripts
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
COPY run.sh /
RUN chmod +x /run.sh

# Start the Godoo application
ENTRYPOINT ["/bin/sh", "-c", "./entrypoint.sh"]
CMD ["godoo", "run"]
