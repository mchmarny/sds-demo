ARG BUILD_BASE=golang@sha256:05a961fb54f63ba541367e6aefc9a7d4bd9ea2a9f019708c4cb4960e2cbf58fb
ARG FINAL_BASE=gcr.io/distroless/static-debian11@sha256:a01d47d4036cae5a67a9619e3d06fa14a6811a2247b4da72b4233ece4efebd57

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
