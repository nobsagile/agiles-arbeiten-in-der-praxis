#!/bin/bash

# Simple pandoc PDF conversion script
# Usage: ./convert.sh input.md output.pdf

set -e

# Check if correct number of arguments provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <input.md> <output.pdf>"
    echo "Example: $0 buch-v2-pandoc-test.md output.pdf"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found"
    exit 1
fi

# Get current working directory for Docker mounting
CURRENT_DIR=$(pwd)
INPUT_FILENAME=$(basename "$INPUT_FILE")
OUTPUT_FILENAME=$(basename "$OUTPUT_FILE")

echo "Converting $INPUT_FILE to $OUTPUT_FILE using pandoc/extra Docker image with Eisvogel template..."

# --- BEGINN DER KORREKTUR ---
# Baue die Pandoc-Argumente sicher in einem Array auf
PANDOC_ARGS=()

# Check if metadata.yaml exists and add it to the arguments
METADATA_FILE="metadata-pdf.yaml"
if [ -f "$METADATA_FILE" ]; then
    echo "Using metadata from: $METADATA_FILE"
    PANDOC_ARGS+=("$METADATA_FILE")
else
    echo "No metadata.yaml found, using defaults"
fi

# Füge die Haupt-Input-Datei hinzu
PANDOC_ARGS+=("$INPUT_FILENAME")

# Run pandoc in Docker container with Eisvogel template
docker run --rm \
    --platform linux/amd64 \
    -v "$CURRENT_DIR:/workspace" \
    -w /workspace \
    pandoc/extra:latest \
    "${PANDOC_ARGS[@]}" \
    -o "$OUTPUT_FILENAME" \
    --template=eisvogel \
    --pdf-engine=xelatex \
    --from=markdown \
    --to=pdf \
    --citeproc \
    --toc \
    --toc-depth=2 \
    --number-sections \
    --listings \
    --top-level-division=chapter
# --- ENDE DER KORREKTUR ---

# Check if output file was created
if [ -f "$OUTPUT_FILE" ]; then
    echo "✓ Conversion complete! Output saved as: $OUTPUT_FILE"
    ls -lh "$OUTPUT_FILE"
else
    echo "✗ Conversion failed! No output file created."
    exit 1
fi