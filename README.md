# iOS Camera Extractor

This script helps you to extract, convert, and generate a PDF from images taken with an iOS device. It converts HEIC images to PNG and JPG formats, resizes them to a resolution of 2048px, and creates a printable PDF with two images per page.

## Features:

- Converts HEIC images to PNG and JPG.
- Resizes images to a maximum of 2048px while maintaining the aspect ratio.
- Generates a PDF with 2 images per page for printing.
- Generates a printable PDF with 1, 2, 4, or more images per page
- Optionallly adds a white border around each image in the PDF

## Prerequisites

Before you install and use the ios-camera-extractor script, make sure you have the following installed:

1. ImageMagick: This is used for converting images and resizing.

    - To install on macOS via Homebrew:

        ```sh
        brew install imagemagick
        ```

2. Man Page Tools (Optional, for installing the man page):

    - On macOS, this is typically available by default.

## Installation

1. Clone the Repository

First, clone the repository to your local machine:

```sh
git clone https://github.com/yourusername/ios-camera-extractor.git
cd ios-camera-extractor
```

2. Make the Script Executable

Ensure that the script has executable permissions:

```sh
chmod +x ios-camera-extractor.sh
```

3. Install the Script Globally

To run the script from anywhere, we need to create a symbolic link in `/usr/local/bin` (or another directory in your `$PATH`).

Run the following command:

```sh
sudo ln -s $(pwd)/ios-camera-extractor.sh /usr/local/bin/ios-camera-extractor
```

This will allow you to run the script from any directory using the command ios-camera-extractor.

4. (Optional) Install the Man Page

To install the man page for the script, follow these steps:

**Step 1: Copy the Man Page to the Correct Directory**

On macOS, the man page should be placed in /usr/local/share/man/man1/. Run the following command to copy the ios-camera-extractor.1 file:

```sh
sudo cp ios-camera-extractor.1 /usr/local/share/man/man1/
```

**Step 2: Update the Man Database**

In most cases, macOS automatically updates the man database, but if it doesn’t, you can force it by running:

```sh
sudo /usr/libexec/locate.updatedb
```

Now, you can view the man page by running:

```sh
man ios-camera-extractor
```

## Usage

To use the script, simply pass an image file path pattern to the command. For example:

```sh
ios-camera-extractor "PATTERN" [--images-per-page NUM] [--border]
```
## Options

- `--images-per-page NUM`: Number of images per PDF page (default: 2)
- `--border`: Adds a small white border around each image in the PDF

## Notes:

Make sure to wrap the pattern in quotes to prevent shell expansion before the script runs. For example, use "IMG_59*" instead of IMG_59*.

You can match multiple files with patterns like:

- `*.HEIC` → Matches all HEIC files in the current directory.
- `IMG_59*` → Matches files starting with `IMG_59`.
- `IMG_????.HEIC` → Matches files starting with `IMG_` followed by exactly 4 characters (e.g., `IMG_1234.HEIC`).

---

## Examples

### Converting all HEIC files:

```sh
ios-camera-extractor "*.HEIC"
```

### Converting images starting with `IMG_59`:

```sh
ios-camera-extractor "IMG_59*"
```

### Converting images starting with `IMG_59`, add 4 to one pdf page and add a 10px border around each image in the pdf

```sh
ios-camera-extractor "IMG_59*" --images-per-page 4 --border
```

### Output

- The script will create a folder named `camera_extractions_YYYYMMDDHHMMSS` in your current directory.
- The folder will contain:
    - `png/` – Full-resolution PNGs
    - `jpg/` – Resized JPEGs
    - `pdfpages/` – Intermediate JPEG pages for PDF
    - `printable_output.pdf` – Final output with 1, 2 or 4 images per page for printing


#### Example Structure:

```
camera_extractions_YYYYMMDDHHMMSS
├── jpg
│   ├── IMG_5946.jpg
│   └── IMG_5947.jpg
├── pdfpages
│   └── page_IMG_5946.jpg
├── png
│   ├── IMG_5946.png
│   └── IMG_5947.png
└── printable_output.pdf
```

### Troubleshooting

**1. Script not found:**

If the script isn’t found when running ios-camera-extractor:

    Ensure that the symbolic link was created correctly:

    ```sh
    ls -l /usr/local/bin/ios-camera-extractor
    ```

    Make sure /usr/local/bin/ is in your $PATH.

**2. Man page not working:**

If you cannot view the man page:

- Ensure the file was copied to `/usr/local/share/man/man1/`:

```sh
ls /usr/local/share/man/man1/ios-camera-extractor.1
```

- If the man page doesn’t update, force a database update:

```sh
sudo /usr/libexec/locate.updatedb
```

