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
FROM alpine:3.13
COPY --from=build /godoo/godoo $HOME/go/bin/godoo
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x entrypoint.sh
COPY run.sh ./run.sh
RUN chmod +x run.sh
RUN chmod +x $HOME/go/bin/godoo
ENTRYPOINT ["./entrypoint.sh"]
CMD ["./run.sh"]