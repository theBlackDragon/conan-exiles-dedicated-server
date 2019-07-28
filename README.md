# What?
This is a Dockerfile allowing you to run the Conan Exiles Dedicated 
Server inside of a Docker container, through Wine.

# Requirements
Requires the [steamcmd](https://github.com/theBlackDragon/steamcmd) 
base image to be present (clone and run the Makefile)

# How to use this image

The image includes a Makefile that can be used to build it by just
typing `Make`

To create a container from the image, assuming the default image name
set by the Makefile:
```console
$ docker create 
    --name conan 
    -p7777:7777/udp 
    -p7778:7778/udp 
    -p27015:27015/udp 
    -e PUID=1000 
    -e PGID=1000 
    -v /mnt/docker/conan:/home/steam/conan-dedicated 
    bgeens/conan-exiles-server:0.1
```

# Exposed ports
 |Port   |Protocol | Function |
 |-------|---------|----------|
 |  7777 | UDP | game port (direct connections) |
 |  7778 | UDP | game port (connections through Steam |
 | 27015 | UDP | steam server browser port |

# Exposed variables
To map the internally used group and user to ones existing on the host 
machine:

 - PUID : the user ID for use by the server process
 - PGID : the group ID for use by the server process
 
Not setting these is likely to lead to all kinds of permission errors.

# Known issues
 - The created container does not show up in the Steam or ingame 
   server browsers for me. Direct connections through IP do work 
   though (but I have to type in the address twice, once  to connect 
   and again after it fails to automatically connect after a the 
   restart to activate appropriate mods)
   
   This might be something on my end, or related to some issue in the
   server software itself. Scanning for the server from Steam always 
   leads to one of these showing up in the dedicated server logs:
   ```
   PacketHandlerLog:Error: PacketHandler parsing packet with zero's in last byte.
   002c:err:eventlog:ReportEventW L"PacketHandler parsing packet with zero's in last byte."
   
   ```
   This is over a LAN from a different machine, so no firewall or port
   conflicts should be involved.
 
