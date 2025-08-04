#!/usr/bin/env bash

printf "\033]52;c;%s\007" "$(gbase64 -w0 < /dev/stdin)"
