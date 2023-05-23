# syntax = docker/dockerfile:1.4
FROM ocaml/opam:ubuntu-22.04-ocaml-4.07 AS build-2.04

SHELL ["/bin/bash", "-e", "-c"]
ENV DEBIAN_FRONTEND noninteractive

RUN <<EOT
sudo apt-get update
sudo apt-get install -y wget graphviz libgtk2.0-dev
opam install ocamlfind
opam install lablgtk=2.18.6

eval $(opam env)

wget https://bblanche.gitlabpages.inria.fr/proverif/proverif2.04.tar.gz
tar xvf proverif2.04.tar.gz
cd proverif2.04
./build
sudo cp {proverif*,addexpectedtags,analyze} /usr/local/bin/
EOT

FROM ubuntu:22.04 AS proverif-2.04

SHELL ["/bin/bash", "-e", "-c"]
ENV DEBIAN_FRONTEND noninteractive

COPY --from=build-2.04 /usr/local/bin/ /usr/local/bin/

RUN <<EOT
apt-get update
apt-get install -y git wget python3 python3-pip graphviz libgtk2.0

python3 -m pip install -U pip

apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
EOT

WORKDIR /workdir