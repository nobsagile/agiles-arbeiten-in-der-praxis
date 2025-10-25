#!/bin/bash

# Pandoc ePub conversion script
# Usage: ./convert-epub.sh input.md output.epub

set -e

# Check if correct number of arguments provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <input.md> <output.epub>"
    echo "Example: $0 buch-v7.md buch.epub"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

CURRENT_DIR=$(pwd)
INPUT_FILENAME=$(basename "$INPUT_FILE")
OUTPUT_FILENAME=$(basename "$OUTPUT_FILE")

echo "Converting $INPUT_FILE to $OUTPUT_FILE using pandoc/extra Docker image..."

PANDOC_ARGS=()

# Verwende die ePub-spezifische Metadaten-Datei
METADATA_FILE="metadata-epub.yaml"
if [ -f "$METADATA_FILE" ]; then
    echo "Using ePub metadata from: $METADATA_FILE"
    PANDOC_ARGS+=("$METADATA_FILE")
else
    echo "No metadata-epub.yaml found, using defaults"
fi

PANDOC_ARGS+=("$INPUT_FILENAME")

# Run pandoc in Docker container for ePub generation
docker run --rm \
    --platform linux/amd64 \
    -v "$CURRENT_DIR:/workspace" \
    -w /workspace \
    pandoc/extra:latest \
    "${PANDOC_ARGS[@]}" \
    -o "$OUTPUT_FILENAME" \
    --from=markdown \
    --to=epub \
    --citeproc \
    --toc \
    --toc-depth=2 \
    --number-sections \
    --split-level=1 # Sagt Pandoc, dass H1 (#) ein neues Kapitel beginnt
    # --epub-stylesheet=epub.css # Optional: für eigenes Styling

# Check if output file was created
if [ -f "$OUTPUT_FILE" ]; then
    echo "✓ Conversion complete! Output saved as: $OUTPUT_FILE"
    ls -lh "$OUTPUT_FILE"
else
    echo "✗ Conversion failed! No output file created."
    exit 1
fi