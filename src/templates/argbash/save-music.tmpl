#!/usr/bin/env bash

# m4_ignore(
echo "This is just a script template, not the script (yet) - pass it to 'argbash' to fix this." >&2
exit 11 #)Created by argbash-init v2.11.0
# Rearrange the order of options below according to what you would like to see in the help message.
# ARG_OPTIONAL_SINGLE([title], [t], [Title], )
# ARG_OPTIONAL_SINGLE([artist], [a], [Artist], )
# ARG_OPTIONAL_SINGLE([original-dir-path], , [Directory storing original files], [original])
# ARG_OPTIONAL_SINGLE([normalized-dir-path], , [Direcotry storing normalized files], [normalized])
# ARG_OPTIONAL_SINGLE([input-format], [i], [Input Format: mp3 | flac], [mp3])
# ARG_OPTIONAL_SINGLE([output-format], [o], [Output Format: mp3], [mp3])
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

# ===================== Cache =====================
cache_dir="$HOME/.cache/save-music"
mkdir -p "$cache_dir"

music_cache_path="$cache_dir/$name.$_arg_input_format"

lrc_cache_path=
if [ -n "$_arg_lrc_url" ]; then
  lrc_cache_path="$cache_dir/$name.lrc"
fi

# ===================== Download/Copy =====================
if ! fetch_resource "$_arg_music_url" "$music_cache_path"; then
  echo "error: music download/copy failed" >&2
  exit 1
fi

if [ -n "$_arg_lrc_url" ]; then
  if ! fetch_resource "$_arg_lrc_url" "$lrc_cache_path"; then
    echo "error: lrc download/copy failed" >&2
    exit 1
  fi
fi

# ===================== Conversion =====================
converted_music_path="$music_cache_path"
if [[ "$_arg_input_format" != "$_arg_output_format" ]]; then
  converted_music_path="$cache_dir/$name.$_arg_output_format"
  ffmpeg -hide_banner -i "$music_cache_path" -q 0 -c:v copy "$converted_music_path"
fi

# ===================== Normalization =====================
normalized_path=
if [ "$_arg_normalized_dir" == on ]; then
  mkdir -p "$_arg_normalized_dir_path"
  normalized_path="$_arg_normalized_dir_path/$name.$_arg_output_format"

  case "$_arg_output_format" in
  mp3)
    echo "mp3 normalizing..." >&2
    mp3-normalize "$converted_music_path" --output-folder "$_arg_normalized_dir_path"
    ;;
  flac)
    echo "flac normalizing..." >&2
    flac-normalize "$converted_music_path" --output-folder "$_arg_normalized_dir_path"
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
  cp -n "$music_cache_path" "$_arg_original_dir_path/"
  [ -n "$lrc_cache_path" ] && cp -n "$lrc_cache_path" "$_arg_original_dir_path/"
fi

if [ "$_arg_normalized_dir" == on ] && [ -n "$lrc_cache_path" ]; then
  cp -n "$lrc_cache_path" "$_arg_normalized_dir_path/"
fi

# ^^^  TERMINATE YOUR CODE BEFORE THE BOTTOM ARGBASH MARKER  ^^^

# ] <-- needed because of Argbash
