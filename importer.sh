#/bin/bash

basedir=~
confdir=config_files
progname=`basename "$0"`
for f in `ls -a -I . -I .. $confdir`
do
  if [[ -a "$basedir/$f" ]]
  then
    echo -e "\e[31m$basedir/$f\e[0m currently exists, do you want to diff the two and make changes?"
    echo -e "(\e[32mY\e[0m): Will run: \e[32mvimdiff $confdir/f $basedir/$f\e[0m"
    echo "(n): To continue linking.."
    read ans
    if [[ (${ans:0:1} == "y") || (${ans:0:1} == "") ]]
    then
      vimdiff "$confdir/$f" "$basedir/$f"
      echo "Resolved? (Y/n)"
      read resolved
      if [[ (${resolved:0:1} == "y") || (${resolved:0:1} == "") ]]
      then
        ln -s "$confdir/$f" "$basedir/$f"
      else
        echo "Moving on.."
      fi
    fi
  else
    ln -s "$confdir/$f" "$basedir/$f"
  fi
done
