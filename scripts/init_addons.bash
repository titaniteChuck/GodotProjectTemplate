#!/bin/bash
set -e
set -x

SCRIPT_DIR=$(dirname "$0")
PROJECT_ROOT="$SCRIPT_DIR/.."
GIT_SUBMODULE_FOLDER=$PROJECT_ROOT/addons_submodules
GODOT_ADDONS_FOLDER=$PROJECT_ROOT/addons
GITIGNORE=$PROJECT_ROOT/.gitignore


add_submodule() {
    repo_url=$1
    submodule_name=$(basename $repo_url)
    submodule_name="${submodule_name%.*}"
    submodule_path=$GIT_SUBMODULE_FOLDER/$submodule_name
    if test -d "$submodule_path"; then
        echo "Submodule [$submodule_name] already exists in folder [$GIT_SUBMODULE_FOLDER]"
    else
        git submodule add $1 $submodule_path
    fi

    addon_folder_in_submodule_dir=$(find $submodule_path -name *.cfg -exec dirname {} \;)
    addon_folder_in_godot_addons_dir=$GODOT_ADDONS_FOLDER/$(basename $addon_folder_in_submodule_dir)
    
    if test -L "$addon_folder_in_godot_addons_dir"; then
        echo "SoftLink [$addon_folder_in_godot_addons_dir] already exists in folder [$GODOT_ADDONS_FOLDER]"
    else
        ln -s $addon_folder_in_submodule_dir $addon_folder_in_godot_addons_dir
    fi

    addon_gitignore_entry=addons/$(basename $addon_folder_in_submodule_dir)
    if grep -Fxq "$addon_gitignore_entry" $GITIGNORE
    then
        echo plugin already in .gitignore
    else
        echo $addon_gitignore_entry >> $GITIGNORE
    fi
}

add_submodule git@github.com:poohcom1/godot-run-configs.git
add_submodule git@github.com:rylydou/godot-run-preset.git