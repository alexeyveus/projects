#!/bin/bash

URL="https://jenkins-dev.retailinmotion.com/login"  # Replace with the URL you want to check
INTERVAL=5  # Time in seconds between each check

while true; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)

  if [ "$STATUS" -eq 200 ]; then
    echo "Received 200 OK response from $URL"
    break
  else
    echo "Waiting for 200 OK response... Current status: $STATUS"
    sleep $INTERVAL
  fi
done
