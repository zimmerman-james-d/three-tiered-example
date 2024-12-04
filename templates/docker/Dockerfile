FROM alpine:3.19.1 as baseline

# Set Baseline
SHELL ["/bin/sh", "-o", "pipefail", "-c"]
RUN apk update
RUN apk upgrade -a
#RUN apk add --no-cache \ ##This will serve as your entrypoint to install your application specific dependencies.

# FROM baseline as dependencies

# FROM dependencies as app
RUN mkdir -p /mnt/backend
WORKDIR /mnt/backend
COPY backend /mnt/backend
EXPOSE 80
