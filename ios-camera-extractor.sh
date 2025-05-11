#!/bin/bash

# Usage: ./convert_and_print.sh "*.HEIC" [images-per-page] [border]

set -e

# Check input
if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") \"PATTERN\" [images-per-page] [border]"
  echo "Example: $(basename "$0") \"IMG_59*\" 2 10"
  echo
  echo "⚠️  NOTE: You must wrap the pattern in quotes to prevent the shell from expanding it before the script runs."
  echo "    This ensures the script correctly finds and processes all matching files."
  echo
  echo "More Info:"
  echo "  You can use standard shell wildcard patterns:"
  echo "    - \"*.HEIC\"     → matches all HEIC files"
  echo "    - \"IMG_59*.HEIC\" → matches HEIC files starting with IMG_59"
  echo "    - \"IMG_????.HEIC\" → matches IMG_ followed by exactly 4 characters"
  echo
  echo "Images per page:"
  echo "  - 1 → 1 image per page"
  echo "  - 2 → 2 images per page (default)"
  echo "  - 4 → 4 images per page"
  echo "  - You can specify other values as well."
  echo
  echo "Border:"
  echo "  - 0 → No border (default)"
  echo "  - Any positive integer (e.g., 10) for a white border size around images."
  echo
  exit 1
fi

# Set default value for images per page if not provided
IMAGES_PER_PAGE=2
if [ $# -ge 2 ]; then
    IMAGES_PER_PAGE=$2
fi

# Validate images per page argument
if ! [[ "$IMAGES_PER_PAGE" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: 'images-per-page' should be a positive integer."
    exit 1
fi

# Set default value for border size if not provided
BORDER_SIZE=0
if [ $# -ge 3 ]; then
    BORDER_SIZE=$3
fi

# Timestamp for output directory
timestamp=$(date +"%Y%m%d%H%M%S")
output_dir="camera_extractions_${timestamp}"

# Create output structure
mkdir -p "$output_dir/png" "$output_dir/jpg" "$output_dir/pdfpages"

# Match files
shopt -s nullglob
pattern="$1"
files=( $pattern )

if [ ${#files[@]} -eq 0 ]; then
    echo "No files matched the pattern '$1'"
    exit 1
fi

echo "Found ${#files[@]} files to process."

# Process each file
for file in "${files[@]}"; do
    filename=$(basename "$file")
    name="${filename%.*}"

    echo "Processing: $filename"

    # Convert to PNG (original resolution)
    magick "$file" "$output_dir/png/${name}.png"

    # Resize for JPG (max 2048px side)
    dimensions=$(magick identify -format "%w %h" "$file")
    width=$(echo $dimensions | cut -d' ' -f1)
    height=$(echo $dimensions | cut -d' ' -f2)

    if [ "$width" -gt "$height" ]; then
        resize="2048x"
    else
        resize="x2048"
    fi

    magick "$file" -resize $resize -quality 85 "$output_dir/jpg/${name}.jpg"
done

# Generate PDF from resized JPGs
echo "Creating printable PDF..."

# Sort JPGs naturally
jpg_files=("$output_dir/jpg"/*.jpg)
sorted_jpgs=($(printf "%s\n" "${jpg_files[@]}" | sort -V))

# Determine the layout for the images per page
case $IMAGES_PER_PAGE in
  1)
    # 1 image per page (stack vertically)
    layout="1x1"
    ;;
  2)
    # 2 images per page (side by side)
    layout="2x1"
    ;;
  4)
    # 4 images per page (2x2 grid)
    layout="2x2"
    ;;
  *)
    echo "Unsupported images-per-page value. Only 1, 2, and 4 are supported."
    exit 1
    ;;
esac

# Combine images into pages with optional border
for ((i=0; i<${#sorted_jpgs[@]}; i+=$IMAGES_PER_PAGE)); do
    img_group=("${sorted_jpgs[@]:i:$IMAGES_PER_PAGE}")

    # Construct the filename for the page
    pairname=$(basename "${img_group[0]}" | cut -d. -f1)

    # Apply border if requested
    if [ "$BORDER_SIZE" -gt 0 ]; then
        # Add white border to images
        for img in "${img_group[@]}"; do
            magick "$img" -bordercolor white -border ${BORDER_SIZE}x${BORDER_SIZE} "$img"
        done
    fi

    # Generate the page with the specified layout
    magick montage "${img_group[@]}" -tile $layout -geometry +0+0 "$output_dir/pdfpages/page_${pairname}.jpg"
done

# Combine into final PDF
magick "$output_dir/pdfpages"/*.jpg "$output_dir/printable_output.pdf"

echo "Done."
echo "Output saved in: $output_dir"

