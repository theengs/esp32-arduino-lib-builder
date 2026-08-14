#/bin/bash

source ./tools/config.sh

if ! [ -x "$(command -v $SED)" ]; then
  	echo "ERROR: $SED is not installed! Please install $SED first."
  	exit 1
fi

#
# CLONE ESP-IDF
#

if [ ! -d "$IDF_PATH" ]; then
	echo "ESP-IDF is not installed! Installing local copy"
	git clone $IDF_REPO_URL -b $IDF_BRANCH
	idf_was_installed="1"
fi

git -C "$IDF_PATH" fetch --all --tags

if [ "$IDF_TAG" ]; then
    git -C "$IDF_PATH" checkout "tags/$IDF_TAG"
    idf_was_installed="1"
elif [ "$IDF_COMMIT_PINNED" ]; then
    # IDF_COMMIT_PINNED, not IDF_COMMIT: config.sh overwrites the latter with
    # whatever HEAD already is (see the note there), which turned this checkout
    # into a no-op and made `build.sh -i` silently ignored on developer
    # machines. Fail loudly if the pin can't be checked out rather than
    # building against an unknown ESP-IDF.
    if ! git -C "$IDF_PATH" checkout "$IDF_COMMIT_PINNED"; then
        echo "ERROR: could not check out pinned ESP-IDF commit $IDF_COMMIT_PINNED" >&2
        exit 1
    fi
    commit_predefined="1"
fi

#
# UPDATE ESP-IDF TOOLS AND MODULES
#

if [ ! -x $idf_was_installed ] || [ ! -x $commit_predefined ]; then
	git -C $IDF_PATH submodule update --init --recursive
	echo "Installing ESP-IDF..."
	$IDF_PATH/install.sh > /dev/null
	export IDF_COMMIT=$(git -C "$IDF_PATH" rev-parse --short HEAD)
	export IDF_BRANCH=$(git -C "$IDF_PATH" symbolic-ref --short HEAD || git -C "$IDF_PATH" tag --points-at HEAD)

	# Temporarily patch the ESP32-S2 I2C LL driver to keep the clock source
	#cd $IDF_PATH
	#patch -p1 -N -i $AR_PATCHES/esp32s2_i2c_ll_master_init.diff
	#cd -
fi

#
# SETUP ESP-IDF ENV
#

source $IDF_PATH/export.sh
