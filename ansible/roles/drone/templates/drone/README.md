# drone data

The drone-server will have this directory mapped to its `/var/lib/drone`
(see docker-compose volume map: ./drone:/var/lib/drone/ )

This means that if we burn the host the volume containing drone's sqlite database + https certs will remain intact
