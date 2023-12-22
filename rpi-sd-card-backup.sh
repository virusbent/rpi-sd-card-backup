#!/bin/bash

# Initialize variables
MODEL=""
SIZE=""
IMG_NAME=""

# Function to check if a command is available
command_exists() {
    command -v "$1" &>/dev/null
}

# Function to display help message
show_help() {
    echo "Create a shrunken backup image of a Raspberry Pi SD card."
    echo "Usage: $0 <path-to-sd-card> <destination-path> [<image-name>] [-h|--help] [-m|--model MODEL] [-s|--size SIZE]"
    echo "  -h, --help      Show this help message"
    echo "  -m, --model     Specify the model of the Raspberry Pi being backed up"
    echo "  -s, --size      Specify the size of the SD card being backed up"
}

# Cleanup function to remove temporary files
cleanup() {
    echo "Cleaning up temporary files..."
    if [[ -n "$IMG_NAME" ]]; then
        rm -f "$IMG_NAME"
        echo "Removed temporary image file: $IMG_NAME"
    fi
    # Check if pishrink.sh exists and remove it.
    if [ -f "pishrink.sh" ]; then
        rm "pishrink.sh"
        echo "Removed PiShrink script."
    fi
    # Add any additional cleanup commands here
}

# Error handling function
error_exit() {
    # Redirect output to stderr
    echo "Error: $1" >&2
    cleanup
    echo "Good Bye."
    exit 1
}

# Trap any errors or interruptions
trap 'error_exit "An unexpected error occurred."' ERR
trap 'error_exit "Received interruption signal, exiting."' SIGINT SIGTERM

# Check for required arguments
if [ "$#" -lt 2 ]; then
    show_help
    exit 1
fi

# Parse positional arguments
SD_CARD="$1"
DEST_PATH="$2"
shift 2

# Parse optional arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -m|--model)
            shift
            MODEL="_$1"
            ;;
        -s|--size)
            shift
            SIZE="_$1"
            ;;
        *)
            if [[ -z "$IMG_NAME" && ! "$1" =~ ^- ]]; then
                IMG_NAME="$1"
            fi
            ;;
    esac
    shift
done

# Set default image name if not provided
IMG_NAME="${IMG_NAME:-rpi${MODEL}${SIZE}_backup_$(date +"%Y%m%d").img}"

# Description and dependencies
echo "This script will perform the following operations:"
echo "1. Create a base image from the SD card."
echo "2. Shrink the image with PiShrink."
echo "3. Compress the image with 7-Zip."
echo
echo "The following dependencies are used:"
echo "- parted"
echo "- xz-utils"
echo "- p7zip-full"
echo

echo "Parameters:"
echo "image-name=$IMG_NAME"
echo "src=$SD_CARD"
echo "dest=$DEST_PATH"
echo

# Confirmation
read -p "Do you want to proceed? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Install prerequisites
to_install=""
if ! command_exists "parted"; then
    to_install+="parted "
fi

if ! command_exists "xz"; then
    to_install+="xz-utils "
fi

if ! command_exists "7z"; then
    to_install+="p7zip-full"
fi

if [ "$to_install" != "" ]; then
    sudo apt-get update
    sudo apt-get install -y $to_install
fi

# Check if destination folder exists, and create it if not
if [ ! -d "$DEST_PATH" ]; then
    mkdir -p "$DEST_PATH"
fi

# Step 1: Create a base image
sudo dd if=$SD_CARD of=$IMG_NAME bs=4M status=progress

# Step 2: Download and make PiShrink executable
wget -O ./pishrink.sh https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
chmod +x ./pishrink.sh

# Step 3: Run PiShrink
sudo ./pishrink.sh -v $IMG_NAME

# Step 4: Compress the image with 7-Zip
7z a -txz -mx9 $DEST_PATH/$IMG_NAME.xz $IMG_NAME

# Step 5: Clean up
cleanup

# Change ownership of the backup file and destination directory
sudo chown -R $USER:$USER $DEST_PATH

echo "Backup completed successfully!"
echo "You can find your backup at $DEST_PATH/$IMG_NAME.xz"
echo "To write the compressed image on sd-card use balenaEtcher. (Recommended)"
echo "Good Bye!"
echo
exit 0