#!/bin/bash

if [[ -f ~/life.7z ]]
then
    echo "Existing life.7z, rotating"
    mv ~/life.7z ~/life.7z.backup
fi

echo "Running 7z command"

7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on ~/life.7z ~/life
echo "Created life.7z"

du -h ~/life.7z

# TODO: send 2 da cloud

echo "backing up to zamn"
scp ~/life.7z zamn:/home/zamn/.
