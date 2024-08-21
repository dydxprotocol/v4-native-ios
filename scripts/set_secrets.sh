#!/bin/sh

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$0")
REPO_DIR="$SCRIPT_DIR/.."
CONFIG_DIR="$REPO_DIR/dydxV4/dydxV4/_Configurations"

# Determine whether to use the "secrets" or "secrets_default" directory
SECRETS_DIR="$REPO_DIR/scripts/secrets"
if [ ! -d "$SECRETS_DIR" ] || [ -z "$(ls -A "$SECRETS_DIR")" ]; then
  SECRETS_DIR="$REPO_DIR/scripts/secrets_default"
  echo "Using default (empty) secrets files"
fi

# Verify that the SECRETS_DIR exists before proceeding
if [ ! -d "$SECRETS_DIR" ]; then
  echo "Error: SECRETS_DIR not found at $SECRETS_DIR"
  exit 1
fi

# Initialize a variable to track if any changes were made
changes_made=false

# Loop through all files in the SECRETS_DIR
for src_file in "$SECRETS_DIR"/*; do
  # Get the corresponding path in the CONFIG_DIR
  dest_file="$CONFIG_DIR/$(basename "$src_file")"

  # Check if the destination file exists
  if [ ! -f "$dest_file" ]; then
    cp -f "$src_file" "$dest_file"
    changes_made=true
  else
    # Compare the files, and copy if they differ
    if ! diff -q "$src_file" "$dest_file" > /dev/null 2>&1; then
      cp -f "$src_file" "$dest_file"
      changes_made=true
    fi
  fi
done

# Check if any changes were made
if [ "$changes_made" = true ]; then
  echo "Secrets files were copied. Copy operation complete."
else
  echo "No changes were made to secrets files."
fi
