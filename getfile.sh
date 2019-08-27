#!/usr/bin/env sh

set -e

URI=$@ # eg: gitlab://username/project:master/kubernetes/helm-chart
# eg: github://username/project:master/kubernetes/helm-chart
PROVIDER=$(echo $URI | cut -d: -f1) # eg: gitlab
GIT_URL=$(echo $URI | cut -d: -f2)
REPO=$(echo $URI | cut -d: -f3 | sed -e "s/\/\///") # eg: username/project
BRANCH=$(echo $URI | cut -d: -f4 | cut -d/ -f1) # eg: master
FILEPATH=$(echo $URI | cut -d: -f4 | sed -e "s/$BRANCH\///") # eg: kubernetes/helm-chart

# echo $URI $REPO $BRANCH $FILEPATH >&2

# make a temporary dir
TMPDIR="$(mktemp -d)"
cd $TMPDIR

git init --quiet
git remote add origin git@$GIT_URL:$REPO.git
git pull --depth=1 --quiet origin $BRANCH

if [ -f $FILEPATH ]; then # if a file named $FILEPATH exists
  cat $FILEPATH
else
  echo "Error in plugin 'helm-git': $BRANCH:$FILEPATH does not exists" >&2
  exit 1
fi

# remove the temporary dir
rm -rf $TMPDIR
