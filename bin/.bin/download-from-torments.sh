#!/bin/bash
#set -x

export REMOTE="torments@dir.blarf.me:Download/zamn/"

if [[ -z "$1" ]]
then
    DATE=$(date --iso | sed 's/-/\//g')
else
    DATE=$1
fi

# Grab files only on $DATE
# Remove . entry with grep
files=$(rsync --list-only "$REMOTE" | grep -v "\.$" | grep $DATE | grep -oP "[0-9]{2}:[0-9]{2}:[0-9]{2} \K.*")

echo "Downloading files..."

  # Convert to URL friendly format :)
  # Then rsync
  #echo "$files" | xargs -I{} python -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" {} |xargs -I{} echo "rsync -aHP \"${REMOTE}{}\" ./"

  echo "$files"

  echo "$files" | xargs -I{} rsync -aHP "${REMOTE}{}" ./
