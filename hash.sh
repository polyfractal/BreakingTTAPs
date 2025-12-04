#!/bin/bash

# Check for correct usage
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: The file '$INPUT_FILE' was not found."
    exit 1
fi

# Attempt to get absolute path, fall back to relative if realpath is missing
if command -v realpath >/dev/null 2>&1; then
    ABS_PATH=$(realpath "$INPUT_FILE")
else
    ABS_PATH="$INPUT_FILE"
fi

# Initialize the output file with header
{
    echo "File: $ABS_PATH"
    echo "----------------------------------------"
} > "$OUTPUT_FILE"

# Function to calculate hash, format output, and append to file
calculate_hash() {
    local label=$1
    local cmd=$2

    if command -v "$cmd" >/dev/null 2>&1; then
        # Execute hash command and grab the first column (the hash string)
        local digest=$($cmd "$INPUT_FILE" | awk '{print $1}')
        
        # Print to console and append to file using tee
        printf "%-10s: %s\n" "$label" "$digest" | tee -a "$OUTPUT_FILE"
    else
        echo "Warning: Command '$cmd' not found. Skipping $label."
    fi
}

# Run calculations
calculate_hash "MD5" "md5sum"
calculate_hash "SHA-1" "sha1sum"
calculate_hash "SHA-256" "sha256sum"

echo ""
echo "Success. Hashes saved to '$OUTPUT_FILE'."
