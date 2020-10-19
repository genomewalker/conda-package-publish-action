#!/bin/bash

set -ex
set -o pipefail

go_to_build_dir() {
    if [ ! -z $INPUT_SUBDIR ]; then
        cd $INPUT_SUBDIR
    fi
}

check_if_meta_yaml_file_exists() {
    if [ ! -f meta.yaml ]; then
        echo "meta.yaml must exist in the directory that is being packaged and published."
        exit 1
    fi
}

build_package(){
    ver=( 3.6 3.7 3.8 )
    for i in "${ver[@]}"; do
        conda build -c conda-forge -c bioconda -c genomewalker --python "${i}" --output-folder . .
    done
    conda convert -p osx-64 linux-64/*.tar.bz2
}

upload_package(){
    export ANACONDA_API_TOKEN=$INPUT_ANACONDATOKEN
    anaconda upload --label main linux-64/*.tar.bz2
    anaconda upload --label main osx-64/*.tar.bz2
}

go_to_build_dir
check_if_meta_yaml_file_exists
build_package
upload_package
