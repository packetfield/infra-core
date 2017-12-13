# Notes

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


