# BUILD
FROM golang:1.20 as builder

# copy
WORKDIR /src/
COPY . /src/

# runtime args
ARG VERSION=v0.0.1-default

# args to env vars
ENV VERSION=${VERSION} GO111MODULE=on

# build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath \
    -ldflags="-w -s -X main.version=${VERSION} -extldflags '-static'" \
    -a -mod vendor -o app

# RUN
# FROM cgr.dev/chainguard/static:latest
FROM gcr.io/distroless/static-debian11:nonroot
COPY --from=builder /src/app /app/

WORKDIR /app
ENTRYPOINT ["./app"]
