#!/bin/sh
docker rm -f brain
docker pull u2668/chat-bot-brain
docker run --name brain -p 8080:8080 -d u2668/chat-bot-brain

# for debug
#docker exec -it brain /bin/bash
