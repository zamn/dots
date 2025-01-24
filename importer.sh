#/bin/bash

. bash/.keys.bash
hasStow=`PATH=$PATH:. command -v stow >/dev/null; echo $?`

# This hack will live 4ever
platform=${platform:-$(uname -a | awk '{print $1}')}

# create psql config folder to store history
mkdir -p ~/.config/psql/

if [[ $hasStow -ne 0 ]]
then
  echo "Please install GNU stow through your package manager."
  if [[ "$platform" != "Linux" ]]
  then
    echo "Installing brew packages.."
    # generate via $(brew leaves > brew_packages.txt)
    xargs brew install < brew_packages.txt
  else
    exit 1
  fi
fi

. bash/.keys.bash

if [[ -z $FIREFOX_PROFILE_DIR ]]
then
    echo "WARN: FIREFOX_PROFILE_DIR is not set, will not stow firefox styles"
fi

if [[ -z "$PINEENTRY_PROGRAM" ]]
then
    echo "ERROR: You must set \$PINEENTRY_PROGRAM in .keys.bash to configure gpg"
    exit 1234
fi

# stow all files in top level dirs
for d in `ls -d */ | tr / ' '`
do
  if [[ "$d" = "firefox" ]]
  then
      if [[ -n "$FIREFOX_PROFILE_DIR" ]]
      then
          stow -t "$FIREFOX_PROFILE_DIR" $d
      fi
  else
      stow -t $HOME $d
  fi
  stowResult=$?
done

if [[ "$platform" = "Linux" ]]
then
    sed -i "s/\$\PINEENTRY_PROGRAM/$(eval echo $PINEENTRY_PROGRAM | sed 's/\//\\\//g')/g" gnupg/.gnupg/gpg-agent.conf
    sed -i "s/\$\NPM_CONFIG_TOKEN/$(eval echo $NPM_CONFIG_TOKEN | sed 's/\//\\\//g')/g" ./npm/.npmrc
else
    which gsed 2>&1 >/dev/null
    if [[ `echo $?` -ne 0 ]]
    then
        echo "You must have gsed installed because macs are garbage and ship with a super old version of sed that does not support inline replacement."
    else
        gsed -i "s/\$\PINEENTRY_PROGRAM/$(eval echo $PINEENTRY_PROGRAM | sed 's/\//\\\//g')/g" gnupg/.gnupg/gpg-agent.conf
        gsed -i "s/\$\NPM_CONFIG_TOKEN/$(eval echo $NPM_CONFIG_TOKEN | sed 's/\//\\\//g')/g" ./npm/.npmrc
        gsed -i "s/\$\GITLAB_API_PAT/$(eval echo $GITLAB_API_PAT | sed 's/\//\\\//g')/g" ./npm/.npmrc
    fi
fi

if [[ $stowResult -ne 0 ]]
then
  exit $stowResult
fi

