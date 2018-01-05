#!/usr/bin/env bash

mkdir /root/.ssh
echo "$SSH_KEY" > /root/.ssh/id_rsa
chmod 0600 /root/.ssh/id_rsa

eval `ssh-agent`
ssh-add /root/.ssh/id_rsa
ssh-add -l

ssh-keyscan -H github.com >> /root/.ssh/known_hosts

./bin/gocd-config-update
