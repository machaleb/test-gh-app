FROM golang:1.21-alpine AS build
WORKDIR /src
COPY . .
RUN go mod tidy && CGO_ENABLED=0 go build -o /out/test-gh-app .

FROM alpine:3.20
WORKDIR /app
COPY --from=build /out/test-gh-app /app/test-gh-app
# main.go opens the git repo in the working directory, so include .git
COPY .git /app/.git
ENTRYPOINT ["/app/test-gh-app"]
