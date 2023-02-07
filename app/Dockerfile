ARG BUILD_BASE=golang@sha256:9be8859445523843084e09747a6f25aee06ce92d23ae320e28d7f101dd6a39e2
ARG FINAL_BASE=gcr.io/distroless/static-debian11@sha256:42ddd0c37ff4ccb0b1e0d2839eb846b250f0fbbb7e4a88ebc1634439b7ee8f0e

# BUILD
FROM $BUILD_BASE as builder

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
FROM $FINAL_BASE
LABEL devo.version="${VERSION}"
COPY --from=builder /src/app /app/

WORKDIR /app
ENTRYPOINT ["./app"]
