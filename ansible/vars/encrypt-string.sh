#!/usr/bin/env bash
####
# Usage example
####
# Run something like this:
#
#  ./encrypt-string.sh some_secret_variable "the-actual-secret-goes-here" >> ./shared-secrets.yml
#
# it should add a secret string variable called {{some_secret_variable}} to shared-secrets.yml

KEY="$1"
VAL="$2"


printf "$VAL" | ansible-vault encrypt_string --stdin-name "${KEY}"

