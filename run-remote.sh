#!/bin/sh
deployAddress="188.166.61.20"
ssh root@${deployAddress} docker rm -f brain
ssh root@${deployAddress} docker pull u2668/chat-bot-brain
ssh root@${deployAddress} docker run --name brain -p 8080:8080 -d u2668/chat-bot-brain
