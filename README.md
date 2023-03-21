# What?
This is a Dockerfile allowing you to run the No One Survived Dedicated 
Server inside of a Docker container, through Wine.

Docker Compose:
```
version: "3.2"

services:
  nos:
    image: ladyviktoria/noonesurviveddedicated:latest
    container_name: nos
    restart: "unless-stopped"
    volumes:
      - /srv/nos-dedicated:/home/steam/nos-dedicated
    environment:
      - PUID=1000
      - PGID=1000
    ports:
      - 7767:7767/udp
      - 7768:7768/udp
      - 27014:27014/udp
```
