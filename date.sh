#!/usr/bin/env bash

DATE=`date -v+120M +%Y-%m-%dT%H:%M:%SZ`

echo -e "{\n  \"date\": \""$DATE"\"\n}"