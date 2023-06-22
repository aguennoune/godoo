# Development stage
FROM golang:1.16.3-alpine3.13 as dev
WORKDIR /godoo
COPY go.mod go.sum ./
RUN go mod download golang.org/x/tools
COPY . .

# Build stage
FROM dev as build
RUN apk add --no-cache git
RUN go build -o godoo

# Runtime stage
FROM alpine:3.13 as runtime
COPY --from=build /godoo/godoo /usr/local/bin/godoo
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
COPY run.sh /
RUN chmod +x /run.sh
RUN chmod +x /usr/local/bin/godoo
RUN apk add --no-cache python3 py3-pip
ENTRYPOINT ["./entrypoint.sh", "run.sh"]
