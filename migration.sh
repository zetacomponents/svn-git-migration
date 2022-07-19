#!/bin/bash

MIG_SVN_PATH="/full/path/to/zetacomponents/svn/repo/"
MIG_SVN_SERVER_SSH_URI="zetacomponents@svn.apache.org:/home/svn/repos/asf/incubator/zetacomponents"
MIG_USERS="users.txt"
MIG_DIR="migration"
MIG_GITHUB="git@github.com:zetacomponents/zeta.git"
TMP_SIZE="600M"
TMP_INODES="100k"

if [ -z "${SSH_AGENT_PID}" -o -z "${SSH_AUTH_SOCK}" ]; then
    echo "ssh-agent not found"
    exit 1
fi

# Syncing with rsync from svn server over ssh
echo -e "\033[1mSyncing\033[0m"
rsync -havz -e ssh $MIG_SVN_SERVER_SSH_URI $MIG_SVN_PATH

# To speedup the process, mounting a directory in memory with tmpfs
echo -e "\033[1mCreating migration directory\033[0m"
mkdir $MIG_DIR
sudo mount -t tmpfs tmpfs -o size=$TMP_SIZE,nr_inodes=$TMP_INODES $MIG_DIR
cd $MIG_DIR

echo -e "\033[1mImporting to git\033[0m"
svn2git -v --trunk trunk --authors $MIG_USERS file://$MIG_SVN_PATH > ../svn2git.out 2> ../svn2git.err

cd ..

echo -e "\033[1mCopying to new directory\033[0m"
cp --recursive --preserve $MIG_DIR $MIG_DIR.copy

cd $MIG_DIR.copy

# For eZ Publish, branches were stored inside /stable directory and tags under /release, zeta has a much more
# complex model...
#
# # Renaming branches, they are prefixed with "stable-"
# echo -e "\033[1mRenaming branches\033[0m"
# for branch in $(svn ls file://$MIG_SVN_PATH/stable | sed 's/\///') ; do git branch -m $branch stable-$branch ; done
#
# # Renaming tags, they are prefixed with "release-"
# echo -e "\033[1mRenaming tags\033[0m"
# for branch in $(svn ls file://$MIG_SVN_PATH/release | sed 's/\///') ; do git branch -m $branch release-$branch ; done

echo -e "\033[1mConfiguring github\033[0m"
git remote add origin $MIG_GITHUB

echo -e "\033[1mPushing to github\033[0m"
git push origin master

# echo -e "\033[1mPushing branches to github\033[0m"
# git push origin $(git branch | grep release)
# git push origin $(git branch | grep stable)
