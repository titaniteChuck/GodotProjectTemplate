#!/bin/bash
set -e # script fails at first error
# set -x # prints every line evaluated
export MSYS=winsymlinks:nativestrict #for git bash windows to make proper ln. Note: Git bash must have been installed with "enabled symlinks" ticked

SCRIPT_DIR=$(dirname "${0}")
PROJECT_ROOT="${SCRIPT_DIR}/.."
GIT_SUBMODULE_FOLDER=$(realpath --relative-to=$PWD ${PROJECT_ROOT}/addons_submodules)
GODOT_ADDONS_FOLDER=$(realpath --relative-to=$PWD ${PROJECT_ROOT}/addons)
GITIGNORE=$(realpath --relative-to=$PWD ${PROJECT_ROOT}/.gitignore)

ADDONS_LIST=(
    git@github.com:poohcom1/godot-run-configs.git
    git@github.com:rylydou/godot-run-preset.git
)

_init_directories() {
    echo -n "Creating the folders structure if not present... "
    mkdir -p $GIT_SUBMODULE_FOLDER
    mkdir -p $GODOT_ADDONS_FOLDER
    [[ $(tail -c1 $GITIGNORE) && -f $GITIGNORE ]] && echo '' >> $GITIGNORE # ensures gitignore ends with a newline
    echo "Done"
}

_init_variables_from_git_url() {
    GIT_REPO_FULL_URL=${1}
    
    GIT_REPO_PROJECT_NAME=$(basename ${GIT_REPO_FULL_URL})
    GIT_REPO_PROJECT_NAME="${GIT_REPO_PROJECT_NAME%.*}"

    GIT_REPO_CLONE_FOLDER=${GIT_SUBMODULE_FOLDER}/${GIT_REPO_PROJECT_NAME}

    if test -d "${GIT_REPO_CLONE_FOLDER}"; then
        ADDON_FOLDER_IN_SUBMODULE_DIR=$(find ${GIT_REPO_CLONE_FOLDER} -name *.cfg -exec dirname {} \;)
        ADDON_FOLDER_NAME=$(basename ${ADDON_FOLDER_IN_SUBMODULE_DIR})
        ADDON_FOLDER_IN_GODOT_ADDONS_DIR=${GODOT_ADDONS_FOLDER}/${ADDON_FOLDER_NAME}

        ADDON_GITIGNORE_ENTRY=addons/${ADDON_FOLDER_NAME}
    fi
}

_init_variables_from_existing_submodule() {
    GIT_REPO_FULL_URL=

    GIT_REPO_CLONE_FOLDER=${1}
    GIT_REPO_PROJECT_NAME=$(basename ${GIT_REPO_CLONE_FOLDER})

    if test -d "${GIT_REPO_CLONE_FOLDER}"; then
        ADDON_FOLDER_IN_SUBMODULE_DIR=$(find ${GIT_REPO_CLONE_FOLDER} -name *.cfg -exec dirname {} \;)
        ADDON_FOLDER_NAME=$(basename ${ADDON_FOLDER_IN_SUBMODULE_DIR})
        ADDON_FOLDER_IN_GODOT_ADDONS_DIR=${GODOT_ADDONS_FOLDER}/${ADDON_FOLDER_NAME}

        ADDON_GITIGNORE_ENTRY=addons/${ADDON_FOLDER_NAME}
    fi
}

remove_unused_submodules() {
    echo "Start removal of all installed addons that are not on the list... ==>"
    for submodule in ${GIT_SUBMODULE_FOLDER}/*/; do
        local present_submodule_name=$(basename ${submodule})
        if [[ "${present_submodule_name}" == "*" ]]; then
            continue
        fi
        local must_delete=true
        for addon_wanted in "${ADDONS_LIST[@]}" ; do
            _init_variables_from_git_url ${addon_wanted}
            if [[ "${present_submodule_name}" == "${GIT_REPO_PROJECT_NAME}" ]]; then
                must_delete=false
                break
            fi
        done
        if ${must_delete}; then
            _init_variables_from_existing_submodule ${submodule}
            echo "Start deletion of [${GIT_REPO_PROJECT_NAME}]"
            rm -f ${ADDON_FOLDER_IN_GODOT_ADDONS_DIR}
            sed -i "\\|$ADDON_GITIGNORE_ENTRY|d" ${GITIGNORE}
            # git rm ${submodule} > /dev/null
        fi
    done
    echo "Done <==="
}


install_new_modules() {
    echo "Start installation of all wanted addons... ==>"
    for addon_git_path in "${ADDONS_LIST[@]}" ; do
        _init_variables_from_git_url ${addon_git_path}
        add_submodule
    done
    echo "Done"
}

add_submodule() {
    echo
    echo Installing ${GIT_REPO_PROJECT_NAME}
    if test -d "${GIT_REPO_CLONE_FOLDER}"; then
        echo "Submodule [${GIT_REPO_PROJECT_NAME}] already exists in folder [$(dirname "${GIT_REPO_CLONE_FOLDER}")]"
    else
        echo "Cloning repo"
        git submodule add --force ${GIT_REPO_FULL_URL} ${GIT_REPO_CLONE_FOLDER}
        _init_variables_from_git_url ${GIT_REPO_FULL_URL}
    fi
    
    if test -L "${ADDON_FOLDER_IN_GODOT_ADDONS_DIR}"; then
        echo "SoftLink [${ADDON_FOLDER_IN_GODOT_ADDONS_DIR}] already exists in folder [${GODOT_ADDONS_FOLDER}]"
    else
        echo "Creating symlink"
        ln -s ${PWD}/${ADDON_FOLDER_IN_SUBMODULE_DIR} ${ADDON_FOLDER_IN_GODOT_ADDONS_DIR}
    fi

    if grep -Fxq "${ADDON_GITIGNORE_ENTRY}" ${GITIGNORE}
    then
        echo plugin already present in .gitignore
    else
        echo "Adding entry in .gitignore"
        echo ${ADDON_GITIGNORE_ENTRY} >> ${GITIGNORE}
    fi
}


_init_directories
echo

echo -n "Exec 'git submodule init' in case it had not been done before... "
git submodule init
echo "Done"
echo

remove_unused_submodules
echo

echo -n "Exec 'git submodule update' to get the latest versions branches... "
git submodule update
echo "Done"
echo

install_new_modules