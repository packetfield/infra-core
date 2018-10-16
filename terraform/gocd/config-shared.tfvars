# GOCD does all the terraform+ansible

size = "custom-2-2048"
region = "europe-west2"
zone = "europe-west2-a"
data_volume_size = 20

# Scopes
# devstorate.read_write is the important one here
# https://cloud.google.com/storage/docs/authentication#oauth-scopes
# TODO: find out if we need the others?

scopes = [
  "https://www.googleapis.com/auth/devstorage.read_write",
  "https://www.googleapis.com/auth/cloud-platform",
  "https://www.googleapis.com/auth/compute",
  ]

