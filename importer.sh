#/bin/bash

basedir=~
progname=`basename "$0"`
files=`ls -aI $progname -I . -I .. -I .git`
for f in $files
do
  if [[ -a "$basedir/$f" ]]
  then
    echo -e "\e[31m$basedir/$f\e[0m currently exists, do you want to diff the two?"
    echo -e "(\e[32mY\e[0m): Will run: \e[32mvimdiff $basedir/$f $f\e[0m"
    echo "(n): To continue linking.."
    read ans
    if [[ (${ans:0:1} == "y") || (${ans:0:1} == "") ]]
    then
      vimdiff $basedir/$f $f
      echo "Resolved? (Y/n)"
      read resolved
      if [[ (${resolved:0:1} == "y") || (${resolved:0:1} == "") ]]
      then
        ln -s "$f" "$basedir/$f"
      else
        echo "Moving on.."
      fi
    fi
  else
    ln -s "$f" "$basedir/$f"
  fi
done
