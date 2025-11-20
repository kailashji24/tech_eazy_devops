#!/bin/bash

# Check if a URL was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <alb-dns-name>"
  exit 1
fi

URL="$1"
echo "Starting load test on $URL..."
echo "Press CTRL+C to stop."

# Infinite loop to hit the ALB
while true; do
  curl -s "$URL" > /dev/null
  # Print a dot for every request to show progress
  echo -n "."
done