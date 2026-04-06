#/bin/bash

source ./tools/config.sh

#
# CLONE/UPDATE TINYUSB
#
echo "Updating TinyUSB..."
TINYUSB_REPO_URL="https://github.com/hathach/tinyusb.git"
TINYUSB_REPO_DIR="$AR_COMPS/arduino_tinyusb/tinyusb"
TINYUSB_TAG="0.20.0"
if [ ! -d "$TINYUSB_REPO_DIR" ]; then
    git clone --branch "$TINYUSB_TAG" --depth 1 "$TINYUSB_REPO_URL" "$TINYUSB_REPO_DIR"
else
    git -C "$TINYUSB_REPO_DIR" fetch --all --tags && \
    git -C "$TINYUSB_REPO_DIR" checkout "$TINYUSB_TAG"
fi
if [ $? -ne 0 ]; then exit 1; fi
