# Raspberry Pi SD Card Backup Script

This script creates a compressed backup image of a Raspberry Pi SD card using PiShrink and 7zip.

## Description

This script performs the following operations:
1. Creates a base image from the SD card using `dd`.
2. Shrinks the image with `PiShrink`.
3. Compresses the image with `7-Zip`.

## Dependencies

These dependencies are checked and installed by the script if not already present.

- parted
- xz-utils
- p7zip-full

## Usage

```bash
./rpi-sd-card-backup.sh <path-to-sd-card> <destination-path> [<image-name>] [-h|--help] <-m|--model MODEL> <-s|--size SIZE>
```

- `<path-to-sd-card>`	: The device path of your SD card (e.g., `/dev/sdb`).
- `<destination-path>`	: The path where the backup image will be saved.
- `[<image-name>]`		: Optional. The name of the backup image file. If not provided, defaults to `rpi_$MODEL_$SIZE_backup_$DATE.img`.
- `-m|--model MODEL`	: Specify the model of the Raspberry Pi.
- `-s|--size SIZE`		: Specify the size of the SD card.
- `-h|--help`			: Show usage message.

## Example

```bash
sudo ./rpi-sd-card-backup.sh /dev/sdb ./backup -m zero2 -s 32gb
```
Image name result rpi_zero2_32gb_backup_20231102.img.xz

```bash
sudo ./rpi-sd-card-backup.sh /dev/sdb ./backup my-image -m zero2 -s 32gb
```
Image name result my-image.img.xz

## Notes

- The script requires sudo privileges to access the SD card and install dependencies.
- For safety, ensure no data is being written to the SD card while the script is running.
- To write the compressed image back to an SD card, it is recommended to use balenaEtcher.
- For `PiShrink` documentation reference: [PiShrink by Drewsif](https://github.com/Drewsif/PiShrink)

## License

This script is released under the MIT License. See the LICENSE file for more details.
