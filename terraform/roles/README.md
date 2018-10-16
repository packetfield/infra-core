# Create service accounts here

Note the outputs are stored in `GCS` so this isn't ideal I guess

The output is base64.. to get the service account file (after pasting said text blob into a file):
```
cat foo.txt | base64 --decode
```
