#!/bin/zsh

export OO_HOME="$HOME/OneOps"
export VGRT_HOME="$PWD"

export PUB_GH="https://github.com"
export PUB_GH_ORIGIN="$PUB_GH/Azure-Refactor"
export PUB_GH_UPSTREAM="$PUB_GH/oneops"

git_clone () {
    # $1 => directory
    # $2 => github user/org url
    # $3 => repo

    if [ -d "$1/$3" ]; then
      echo "doing git pull on $3"
      cd "$1/$3"
      git pull
    else
      echo "doing $3 git clone"
      cd $1
      git clone "$2/$3.git"
    fi
}

git_add_remote () {
    # $1 => directory
    # $2 => github user/org url
    # $3 => repo
    # $4 => remote name

    if [ -d "$1/$3" ]; then
      echo "adding/updating remote on $3"
      cd "$1/$3"
      git remote remove "$4"
      git remote add "$4" "$2/$3.git"
    else
      echo "repo does not exist"
    fi
}

git_pull_remote () {
    # $1 => directory
    # $2 => remote name
    # $3 => repo

    if [ -d "$1/$3" ]; then
      echo "pulling from $2 on $3"
      cd "$1/$3"
      git pull "$2" master
    else
      echo "repo does not exist"
    fi
}

make_directory () {
    # $1 => directory

    if [ -d "$1" ]; then
      echo "directory already exists"
    else
      mkdir "$1"
    fi
}

git_verify () {
    # $1 => directory

    if [ -d "$1" ]; then
        echo "Success: $1"
    else
        echo "Error: $1"
        exit 1
    fi
}

pause () {
    read "?$*"
}

for hostname in "oodev"
do
    make_directory "$OO_HOME"
    make_directory "$OO_HOME/$hostname"

    pause "Make sure you are able to connect to $PUB_GH. Press [ENTER] to continue... "

    git_clone "$OO_HOME/$hostname" "$PUB_GH_ORIGIN" "circuit-oneops-1"
    git_add_remote "$OO_HOME/$hostname" "$PUB_GH_UPSTREAM" "circuit-oneops-1" "upstream"
    git_pull_remote "$OO_HOME/$hostname" "upstream" "circuit-oneops-1"
    git_verify "$OO_HOME/$hostname/circuit-oneops-1"

    git_clone "$OO_HOME/$hostname" "$PUB_GH_ORIGIN" "oneops-admin"
    git_add_remote "$OO_HOME/$hostname" "$PUB_GH_UPSTREAM" "oneops-admin" "upstream"
    git_pull_remote "$OO_HOME/$hostname" "upstream" "oneops-admin"
    git_verify "$OO_HOME/$hostname/oneops-admin"

    cd "$VGRT_HOME"

    vagrant up $hostname
    vagrant reload $hostname
done



