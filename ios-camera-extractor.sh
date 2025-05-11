#!/bin/bash

# Usage: ./convert_and_print.sh "*.HEIC"

set -e

# Check input
if [ $# -eq 0 ]; then
  echo "Usage: $(basename "$0") \"PATTERN\""
  echo "Example: $(basename "$0") \"IMG_59*\""
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
  exit 1
fi

# Timestamp for output directory
timestamp=$(date +"%Y%m%d%H%M%S")
output_dir="camera_extractions_${timestamp}"

# Create output structure
mkdir -p "$output_dir/png" "$output_dir/jpg" "$output_dir/pdfpages"

# Match files
shopt -s nullglob
pattern="$@"
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

# Generate 2-per-page PDF from resized JPGs
echo "Creating printable PDF..."

# Sort JPGs naturally
jpg_files=("$output_dir/jpg"/*.jpg)
sorted_jpgs=($(printf "%s\n" "${jpg_files[@]}" | sort -V))

# Combine every two images into one page using montage
for ((i=0; i<${#sorted_jpgs[@]}; i+=2)); do
    img1="${sorted_jpgs[$i]}"
    img2="${sorted_jpgs[$i+1]:-null:}"  # Fill with blank if odd number
    pairname=$(basename "$img1" | cut -d. -f1)

    magick montage "$img1" "$img2" -tile 1x2 -geometry +0+0 "$output_dir/pdfpages/page_${pairname}.jpg"
done

# Combine into final PDF
magick "$output_dir/pdfpages"/*.jpg "$output_dir/printable_output.pdf"

echo "Done."
echo "Output saved in: $output_dir"

