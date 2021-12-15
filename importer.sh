#/bin/bash

. bash/.keys.bash
hasStow=`PATH=$PATH:. command -v stow >/dev/null; echo $?`

if [[ $hasStow -ne 0 ]]
then
  echo "Please install GNU stow through your package manager."
  exit 1
fi

if [[ -z "$PINEENTRY_PROGRAM" ]]
then
    echo "You *MUST* set \$PINEENTRY_PROGRAM in .keys.bash (at the least) to get stuff working."
    exit 1234
fi

# stow all files in top level dirs
for d in `ls -d */ | tr / ' '`
do
  stow -t $HOME $d
  stowResult=$?
done

# TODO: Make this less hacky
if [[ "$platform" = "Linux" ]]
then
    sed -i "s/\$\PINEENTRY_PROGRAM/$(eval echo $PINEENTRY_PROGRAM | sed 's/\//\\\//g')/g" gnupg/.gnupg/gpg-agent.conf
    sed -i "s/\$\NPM_CONFIG_TOKEN/$(eval echo $NPM_CONFIG_TOKEN | sed 's/\//\\\//g')/g" ~/.npmrc
else
    which gsed 2>&1 >/dev/null
    if [[ `echo $?` -ne 0 ]]
    then
        echo "You must have gsed installed because macs are garbage and ship with a super old version of sed that does not support inline replacement."
    else
        gsed -i "s/\$\PINEENTRY_PROGRAM/$(eval echo $PINEENTRY_PROGRAM | sed 's/\//\\\//g')/g" gnupg/.gnupg/gpg-agent.conf
        gsed -i "s/\$\NPM_CONFIG_TOKEN/$(eval echo $NPM_CONFIG_TOKEN | sed 's/\//\\\//g')/g" ~/.npmrc
        gsed -i "s/\$\GITLAB_API_PAT/$(eval echo $GITLAB_API_PAT | sed 's/\//\\\//g')/g" ~/.npmrc
    fi
fi

if [[ $stowResult -ne 0 ]]
then
  exit $stowResult
fi

