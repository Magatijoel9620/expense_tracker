FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y curl git unzip zip
RUN curl https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_1.22.2-stable.tar.xz | tar -xf -
ENV PATH "$PATH:/flutter/bin"

COPY . /app
WORKDIR /app


RUN flutter build apk --release


CMD ["flutter", "run"]