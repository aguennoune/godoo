# Use a multi-stage build to reduce image size
FROM golang:1.16.3-alpine3.13 AS build

# Install required packages for building the binary
RUN apk add --no-cache \
    build-base \
    git \
    curl \
    wget \
    libssl1.1 \
    libffi \
    libxml2 \
    libxslt \
    zlib \
    postgresql-libs \
    openldap-dev \
    tiff \
    libjpeg-turbo \
    openjpeg \
    freetype \
    lcms2 \
    libwebp \
    harfbuzz \
    fribidi \
    tcl \
    tk \
    python3-dev \
    py3-pip \
    py3-setuptools \
    py3-wheel

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Install Go dependencies
RUN go get github.com/llonchj/godoo

# Set the working directory
WORKDIR /go/src/github.com/llonchj/godoo

# Copy the source code
COPY . .

# Build the binary
RUN go build -o godoo

# Create a new image with only the necessary files
FROM build as runtime

# Install required packages for running the binary
RUN apk add --no-cache \
    libssl1.1 \
    libffi \
    libxml2 \
    libxslt \
    zlib \
    postgresql-libs \
    openldap \
    tiff \
    libjpeg-turbo \
    openjpeg \
    freetype \
    lcms2 \
    libwebp \
    harfbuzz \
    fribidi \
    tcl \
    tk \
    python3 \
    py3-pip \
    py3-setuptools \
    py3-wheel

# Copy the godoo binary from the build stage
COPY --from=build /go/src/github.com/llonchj/godoo/godoo /usr/local/bin/godoo

# Copy the entrypoint script
COPY ./dlv.sh /
RUN chmod +x /dlv.sh

# Set the entrypoint
ENTRYPOINT [ "/dlv.sh" ]