#!/bin/sh
ssh root@46.101.204.43 docker rm -f web-presentation
ssh root@46.101.204.43 docker pull u2668/web-presentation
ssh root@46.101.204.43 run --name web-presentation -p 80:80 --net go-to-canteen -d u2668/web-presentation
