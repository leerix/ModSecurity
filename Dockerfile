FROM busybox:latest

RUN mkdir -p /modsecurity
COPY . /modsecurity
