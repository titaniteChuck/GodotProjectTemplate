#!/bin/bash
set -e
set -x

export MSYS=winsymlinks:nativestrict #for git bash windows to make ln

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT="$SCRIPT_DIR/.."
GIT_SUBMODULE_FOLDER=$PROJECT_ROOT/addons_submodules
GODOT_ADDONS_FOLDER=$PROJECT_ROOT/addons
GITIGNORE=$PROJECT_ROOT/.gitignore

addons=(
    git@github.com:poohcom1/godot-run-configs.git
    # git@github.com:rylydou/godot-run-preset.git
)


add_submodule() {
    local repo_url=$1
    local submodule_name=$(basename $repo_url)
    local submodule_name="${submodule_name%.*}"
    local submodule_path=$GIT_SUBMODULE_FOLDER/$submodule_name
    if test -d "$submodule_path"; then
        echo "Submodule [$submodule_name] already exists in folder [$GIT_SUBMODULE_FOLDER]"
    else
        git submodule add $1 $submodule_path
    fi

    local addon_folder_in_submodule_dir=$(find $submodule_path -name *.cfg -exec dirname {} \;)
    local addon_folder_in_godot_addons_dir=$GODOT_ADDONS_FOLDER/$(basename $addon_folder_in_submodule_dir)
    
    if test -L "$addon_folder_in_godot_addons_dir"; then
        echo "SoftLink [$addon_folder_in_godot_addons_dir] already exists in folder [$GODOT_ADDONS_FOLDER]"
    else
        ln -s $PWD/$addon_folder_in_submodule_dir $addon_folder_in_godot_addons_dir
    fi

    local addon_gitignore_entry=addons/$(basename $addon_folder_in_submodule_dir)
    if grep -Fxq "$addon_gitignore_entry" $GITIGNORE
    then
        echo plugin already in .gitignore
    else
        echo $addon_gitignore_entry >> $GITIGNORE
    fi
}

remove_unused_submodules() {
    for submodule in $GIT_SUBMODULE_FOLDER/*/; do
        local present_submodule_name=$(basename $submodule)
        local must_delete=true
        for addon_wanted in "${addons[@]}" ; do
            local wanted_submodule_name=$(basename $addon_wanted)
            local wanted_submodule_name="${wanted_submodule_name%.*}"
            if [[ $present_submodule_name == $wanted_submodule_name ]]; then
                must_delete=false
                break
            fi
        done
        if $must_delete; then
            echo $submodule should be deleted
            git rm $submodule
        fi
    done
}

# git submodule init
# git submodule update

remove_unused_submodules

# for addon_git_path in "${addons[@]}" ; do
#     add_submodule $addon_git_path
# done
