#!/bin/sh
deployAddress="46.101.204.43"
ssh root@${deployAddress} docker rm -f brain
ssh root@${deployAddress} docker pull u2668/chat-bot-brain
ssh root@${deployAddress} docker run --name brain -p 8081:8080 --net go-to-canteen -d u2668/chat-bot-brain
