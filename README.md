# save-music

Save mp3 using ffmpeg-normalize,
including downloading, adding tags, normalization and saving to directories.

## Usage

save-music -t|--title title -a|--artist artist
[-o|--original-dir original_dir[=original]] [-n|--normalized-dir normalized_dir[=normalized]]
[-i|--input-format input_format=mp3] [-O|--output-format output_format=<mp3|flac>]
<music_url> [lrc_url]

### Example

```sh
# -o -n <lrc_url> are optional
save-music -t title -a artist-name \
  -o where/you/want/to/save/not-modified/music/to \
  -n where/you/want/to/save/the/final/music/to \
  https://music.fake/music.mp3 \
  file:///where/your/dot-lrc-file/is
```

## Dependencies

- kid3-cli: tag
- ffmpeg-normalize: normalization
- curl: downloading

## Note

Flac support might be broken.
