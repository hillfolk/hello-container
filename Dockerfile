FROM golang:1.22-alpine AS builder
WORKDIR /app

# Copy go.mod and go.sum files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the Go application
RUN go build -o /go/bin/app

# Final stage
FROM alpine:3.12
WORKDIR /root/

# Copy the built Go binary from the builder stage
COPY --from=builder /go/bin/app .

# Set the entry point to run the Go application
ENTRYPOINT ["./app"]

WORKDIR /build
COPY go.mod go.sum main.go ./
RUN go mod download
RUN go build -o main .
WORKDIR /dist
RUN cp /build/main .

FROM scratch
COPY --from=builder /dist/main .
ENTRYPOINT ["/main"]