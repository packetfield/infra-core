# Drone integrates with github and does all the PR checks and docker image creation

# Drone will monitor infra-core(develop + master) and trigger terraform/ansible etc in gocd

size = "f1-micro"
region = "europe-west2"
zone = "europe-west2-a"
data_volume_size = 20

# Scopes
# devstorate.read_write is the important one here
# https://cloud.google.com/storage/docs/authentication#oauth-scopes
# TODO: find out if we need the others?

scopes = [
  "https://www.googleapis.com/auth/devstorage.read_write",
  ]

