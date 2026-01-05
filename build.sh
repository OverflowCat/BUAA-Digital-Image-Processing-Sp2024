#!/bin/bash

# Create the dist directory if it doesn't exist
mkdir -p dist

# Define the entry files for each folder
entry_files=(
    "chap02/main.typ"
    "chap03/main.typ"
    "chap04/main.typ"
    "chap09/report.typ"
    "chap10/main.typ"
    "chap11/main.typ"
    "expt01/report.typ"
    "expt02/main.typ"
    "expt03/main.typ"
)

# Compile each entry file into the dist directory
for file in "${entry_files[@]}"; do
    # Extract the folder name and base name of the file (without path and extension)
    folder_name=$(basename $(dirname "$file"))
    base_name=$(basename "$file" .typ)

    # Compile the .typ file to a PDF in the dist directory, including the folder name in the output filename
    output_file="dist/${folder_name}_${base_name}.pdf"
    if ! typst compile "$file" "$output_file" --root .; then
        echo "Compilation failed for file: $file"
        exit 1
    fi
done

echo "All entry .typ files have been compiled into the dist directory:"
ls dist/*.pdf
