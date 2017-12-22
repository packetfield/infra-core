# Status


| develop | master |
|---|---|
| [![staging](https://drone.packetfield.com/api/badges/packetfield/infra-core/status.svg?branch=develop)](https://drone.packetfield.com/packetfield/infra-core) | [![prod](https://drone.packetfield.com/api/badges/packetfield/infra-core/status.svg?branch=master)](https://drone.packetfield.com/packetfield/infra-core) |


## suggested workflow notes
- gitflow for everything, code and infrastructure
- develop branch -> develop infrastructure (aka: staging)
- once your app builds and CI tests pass it is deployed to *develop*
- after integration tests are done against in *develop* (and they pass) the develop branch is automatically merged to master
- the whole process repeats identically on *master* (aka prod)

## Application standards

- `/healthz` endpoints
- `/metrics` prometheus metrics
- all logging to stdout, including errors
- keep them simple as possible
- no secrets in git (except when encrypted via ansible-vault)
- no secrets passed by environmental variables (we have config maps)

# Notes on manually done steps

### Created bucket for terraform state

```
export PROJECT=packetfield
export LOCATION=europe-west1
export BUCKET=gpacketfield-terraform-state

# create the bucket
gsutil mb -p ${PROJECT} -c regional -l ${LOCATION} gs://${BUCKET}/

# enable versioning
gsutil versioning set on  gs://${BUCKET}
```

### manually added NS records

```
# First created the "shared" zone which is **packetfield.com** itself
make ENV=shared COMPONENT=dns apply

# then check the NS servers that were created.. and point the domain/whois records at them
```
(they were ns-cloud-d[1,2,3,4].googledomains.com for the record)


### GCR repo is public

```

export PROJECT_NAME=packetfield
# make all future artifacts open
gsutil defacl ch -u AllUsers:R gs://artifacts.${PROJECT_NAME}.appspot.com

#Make all current objects in the bucket public (eg, the image you just pushed):
gsutil acl ch -r -u AllUsers:R gs://artifacts.${PROJECT_NAME}.appspot.com

# Make the bucket itself public (not handled by -r!):
gsutil acl ch -u AllUsers:R gs://artifacts.${PROJECT_NAME}.appspot.com
```


# Ansible inventory notes

gce.py has been modified to look for an environmental variable..

If its set it will filter the hosts only for those with a tag matching that value.

This ensures we don't accidentally target hosts in other environments

EG:

```
# show all hosts
./ansible/inventory/gce.py| jq .

# show "shared" hosts..
INVENTORY_TAG_FILTER=shared ./ansible/inventory/gce.py| jq .

```

This variable is set in the Makefile based on the `$ENV` at runtime
