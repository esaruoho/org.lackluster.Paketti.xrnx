#!/bin/bash

SEARCH_PHRASE=""
YOUTUBE_URL="https://www.youtube.com/watch?v=vmDiuZmu6Fs"
DOWNLOAD_DIR="/Users/esaruoho/test/"
CLIP_LENGTH="10"
FULL_VIDEO="true"
TEMP_DIR="$DOWNLOAD_DIR/tempfolder"
COMPLETION_SIGNAL_FILE="$TEMP_DIR/download_completed.txt"
FILENAMES_FILE="$TEMP_DIR/filenames.txt"
SEARCH_RESULTS_FILE="$TEMP_DIR/search_results.txt"

echo "Starting PakettiColuga.sh with arguments:"
echo "SEARCH_PHRASE: $SEARCH_PHRASE"
echo "YOUTUBE_URL: $YOUTUBE_URL"
echo "DOWNLOAD_DIR: $DOWNLOAD_DIR"
echo "CLIP_LENGTH: $CLIP_LENGTH"
echo "FULL_VIDEO: $FULL_VIDEO"

mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$TEMP_DIR"

rm -f "$TEMP_DIR"/*.wav
rm -f "$COMPLETION_SIGNAL_FILE"
> "$FILENAMES_FILE"
> "$SEARCH_RESULTS_FILE"

cd "$TEMP_DIR" || exit

sanitize_filename() {
  echo "$1" | tr -cd '[:alnum:]._-'
}

get_random_url() {
  yt-dlp "ytsearch30:" --get-id > "$SEARCH_RESULTS_FILE"
  if [ ! -s "$SEARCH_RESULTS_FILE" ]; then
    echo "No URLs found for the search term."
    exit 1
  fi
  urls=()
  while IFS= read -r line; do
    urls+=("$line")
  done < "$SEARCH_RESULTS_FILE"
  random_index=$((RANDOM % ${#urls[@]}))
  selected_url="https://www.youtube.com/watch?v=${urls[$random_index]}"
  echo "$selected_url"
}

if [ "$YOUTUBE_URL" != "" ]; then
  if [ "$FULL_VIDEO" == "true" ]; then
    echo "Downloading full video from URL..."
    yt-dlp -f ba --extract-audio --audio-format wav -o "${TEMP_DIR}/%(title)s-%(id)s.%(ext)s" "$YOUTUBE_URL"
  else
    echo "Downloading clip of length ${CLIP_LENGTH} seconds from URL..."
    yt-dlp --download-sections "*0-${CLIP_LENGTH}" -f ba --extract-audio --audio-format wav -o "${TEMP_DIR}/%(title)s-%(id)s.%(ext)s" "$YOUTUBE_URL"
  fi
else
  selected_url=$(get_random_url)
  if [ "$FULL_VIDEO" == "true" ]; then
    echo "Downloading full video as audio..."
    yt-dlp -f ba --extract-audio --audio-format wav -o "${TEMP_DIR}/%(title)s-%(id)s.%(ext)s" "$selected_url"
  else
    echo "Downloading clip of length ${CLIP_LENGTH} seconds..."
    yt-dlp --download-sections "*0-${CLIP_LENGTH}" -f ba --extract-audio --audio-format wav -o "${TEMP_DIR}/%(title)s-%(id)s.%(ext)s" "$selected_url"
  fi
fi

# Sanitize filenames
for file in *.wav; do
  [ -e "$file" ] || continue
  sanitized_file=$(sanitize_filename "$file")
  if [ "$file" != "$sanitized_file" ]; then
    mv "$file" "$sanitized_file"
    echo "Renamed '$file' to '$sanitized_file'"
  fi
  echo "$sanitized_file" >> "$FILENAMES_FILE"
done

# Signal completion
touch "$COMPLETION_SIGNAL_FILE"

echo "PakettiColuga.sh finished."
