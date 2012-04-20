#!/bin/bash
REPOSITORY="https://github.com/apache/zetacomponents.git"
ROOT=`pwd`

if [ ! -d "gitbase" ]; then
    git clone "$REPOSITORY" gitbase
fi

for dir in `ls "$ROOT/gitbase"`
do
    COMPONENT=$dir
    cd "$ROOT"
    if [ -d "$ROOT/gitbase/$dir" ]; then
        echo "Converting $COMPONENT"
        rm -Rf $COMPONENT
        rsync -az "$ROOT/gitbase/" "$ROOT/$COMPONENT"
        cd "$ROOT/$COMPONENT"
        git status
        git filter-branch --tag-name-filter cat --prune-empty --subdirectory-filter "$COMPONENT" HEAD

        git reset --hard
        git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d
        git reflog expire --expire=now --all
        git gc --aggressive --prune=now
    fi
done
