# syntax=docker/dockerfile:1
# BASE_IMAGE is the Go base image built from DevOps-BaseImages/Dockerfile/golang
ARG BASE_IMAGE=go-base-ghapp:local

FROM ${BASE_IMAGE} AS build
WORKDIR /src
# Private modules must be listed in GOPRIVATE so Go bypasses the public proxy/sumdb
ENV GOPRIVATE=github.com/machaleb/*
COPY . .
# Optional private module to fetch, e.g. github.com/machaleb/private-mod. The
# build fails if the GitHub App token can't access it, which proves the auth works.
ARG PRIVATE_MODULE=
# The GitHub App secrets exist only for this step and never land in a layer.
# go clean -modcache forces every module to be downloaded fresh.
RUN --mount=type=secret,id=github_app_id \
    --mount=type=secret,id=github_app_installation_id \
    --mount=type=secret,id=github_app_private_key \
    go clean -modcache && \
    if [ -n "${PRIVATE_MODULE}" ]; then go list -m "${PRIVATE_MODULE}@latest"; fi && \
    go mod tidy && CGO_ENABLED=0 go build -o /out/test-gh-app .

FROM alpine:3.20
WORKDIR /app
COPY --from=build /out/test-gh-app /app/test-gh-app
# main.go opens the git repo in the working directory, so include .git
COPY .git /app/.git
ENTRYPOINT ["/app/test-gh-app"]
