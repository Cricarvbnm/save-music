#!/usr/bin/env bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11 #)Created by argbash-init v2.11.0
# Rearrange the order of options below according to what you would like to see in the help message.
# ARG_OPTIONAL_SINGLE([title], [t], [Title], )
# ARG_OPTIONAL_SINGLE([artist], [a], [Artist], )
# ARG_OPTIONAL_SINGLE([original-dir-path], , [Directory storing original files], [original])
# ARG_OPTIONAL_SINGLE([normalized-dir-path], , [Direcotry storing normalized files], [normalized])
# ARG_OPTIONAL_SINGLE([output-format], [o], [Output format: mp3 | flac | same (keep original)], [mp3])
# ARG_OPTIONAL_BOOLEAN([original-dir], [O], [Whether to make original-dir-path], [on])
# ARG_OPTIONAL_BOOLEAN([normalized-dir], [n], [Whether to make normalized-dir-path], [on])
# ARG_POSITIONAL_SINGLE([music-url], [Music URL / Local Path], )
# ARG_POSITIONAL_SINGLE([lrc-url], [LRC URL / Local Path], [""])
# ARG_DEFAULTS_POS
# ARG_HELP([Save music and lycris from URLs/paths with optional normalization and tagging.])
# ARGBASH_GO

# [ <-- needed because of Argbash

# vvv  PLACE YOUR CODE HERE  vvv
# ===================== Restriction =====================
set -euo pipefail
IFS=$'\n\t'

# ===================== Dependency Check =====================
check_dependency() {
  if ! command -v "$1" &>/dev/null; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}
check_dependency curl
check_dependency ffmpeg
check_dependency kid3-cli
check_dependency mp3-normalize
check_dependency flac-normalize

# ===================== Tools =====================
fetch_resource() {
  local source_path="$1"
  local dest_path="$2"
  if [[ -f "$source_path" ]]; then
    cp -- "$source_path" "$dest_path"
    return $?
  fi
  curl -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:141.0) Gecko/20100101 Firefox/141.0' \
    --create-dirs --fail --progress-bar "$source_path" --output "$dest_path"
}

name="$_arg_title - $_arg_artist"

# ===================== Temp Work Directory =====================
work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT

# ===================== Download =====================
music_path="$work_dir/$name"
if ! fetch_resource "$_arg_music_url" "$music_path"; then
  echo "error: music download/copy failed" >&2
  exit 1
fi

lrc_path=
if [ -n "$_arg_lrc_url" ]; then
  lrc_path="$work_dir/$name.lrc"
  if ! fetch_resource "$_arg_lrc_url" "$lrc_path"; then
    echo "error: lrc download/copy failed" >&2
    exit 1
  fi
fi

# ===================== Auto-Detect Input Format =====================
detected_codec=$(ffprobe -v error -select_streams a:0 \
  -show_entries stream=codec_name \
  -of default=noprint_wrappers=1:nokey=1 "$music_path")

case "$detected_codec" in
  mp3)     input_fmt=mp3 ;;
  flac)    input_fmt=flac ;;
  *)       echo "error: unsupported audio format: $detected_codec" >&2; exit 1 ;;
esac

# Rename with correct extension
music_ext="$work_dir/$name.$input_fmt"
mv "$music_path" "$music_ext"

# ===================== Resolve Output Format =====================
if [ "$_arg_output_format" = "same" ]; then
  output_fmt="$input_fmt"
else
  output_fmt="$_arg_output_format"
fi

# ===================== Conversion =====================
converted_path="$music_ext"
if [ "$input_fmt" != "$output_fmt" ]; then
  converted_path="$work_dir/$name.$output_fmt"
  ffmpeg -hide_banner -i "$music_ext" -q 0 -c:v copy "$converted_path"
fi

# ===================== Normalization =====================
normalized_path=
if [ "$_arg_normalized_dir" == on ]; then
  mkdir -p "$_arg_normalized_dir_path"
  normalized_path="$_arg_normalized_dir_path/$name.$output_fmt"

  case "$output_fmt" in
  mp3)
    echo "mp3 normalizing..." >&2
    mp3-normalize "$converted_path" --output-folder "$_arg_normalized_dir_path"
    ;;
  flac)
    echo "flac normalizing..." >&2
    flac-normalize "$converted_path" --output-folder "$_arg_normalized_dir_path"
    ;;
  esac
fi

# ===================== Tagging =====================
if [ -n "$normalized_path" ] && [ -f "$normalized_path" ]; then
  kid3-cli -c "set title '$_arg_title'" \
    -c "set artist '$_arg_artist'" \
    "$normalized_path"
fi

# ===================== Archive =====================
if [ "$_arg_original_dir" == on ]; then
  mkdir -p "$_arg_original_dir_path"
  cp -n "$music_ext" "$_arg_original_dir_path/"
fi

if [ -n "$lrc_path" ]; then
  [ "$_arg_original_dir" == on ] && cp -n "$lrc_path" "$_arg_original_dir_path/"
  [ "$_arg_normalized_dir" == on ] && cp -n "$lrc_path" "$_arg_normalized_dir_path/"
fi

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
