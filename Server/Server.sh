#!/bin/sh
echo -ne '\033c\033]0;Server\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Server.x86_64" "$@"
