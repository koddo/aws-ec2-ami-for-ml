#!/usr/bin/env bash

aws ec2 request-spot-instances \
    --spot-price '0.005' \
    --type 'one-time' \
    --instance-count 1 \
    --launch-specification file://aws.specification.json
        
    # --dry-run \
    # --block-duration-minutes 60 \
    # --client-token 'FF4AABBE-67D4-4B54-BA7F-3F70BBA37C3B' \

# uuidgen | pbcopy



