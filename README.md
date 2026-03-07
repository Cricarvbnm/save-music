# save-music

A lightweight command-line tool to download music and LRC lyrics from URLs/paths, with optional audio normalization and MP3 ID3 tagging.

## Features

- Download/Copy music tracks and lyrics from URLs/paths
- Support for MP3/FLAC input audio formats
- Optional audio normalization processing
- Automatic MP3 ID3 tagging (title/artist metadata)
- Optional and Customizable storage directories for original/normalized files
- Fish shell completion support

## Prerequisites

- bash
- `curl` (for downloading remote media/lyrics)
- ffmpeg and ffmpeg-normalize
- kid3-common (for MP3 tagging)

## Usage

```bash
save-music [OPTIONS] <music-url> [<lrc-url>]
```

## Full Options

```
save-music [-t|--title <arg>] [-a|--artist <arg>] [--original-dir-path <arg>] [--normalized-dir-path <arg>] [-i|--input-format <arg>] [-o|--output-format <arg>] [-O|--(no-)original-dir] [-n|--(no-)normalized-dir] [-h|--help] <music-url> [<lrc-url>]
```

| Option                         | Description                                                   |
| ------------------------------ | ------------------------------------------------------------- |
| `<music-url>`                  | Required Music URL/path                                       |
| `<lrc-url>`                    | Optional LRC lyrics URL/path                                  |
| `-t, --title <value>`          | Set track title (required for tagging)                        |
| `-a, --artist <value>`         | Set track artist (required for tagging)                       |
| `--original-dir-path <path>`   | Directory for original downloaded files (default: `original`) |
| `--normalized-dir-path <path>` | Directory for normalized audio files (default: `normalized`)  |
| `-O, --(no-)original-dir`      | Create/skip original directory (enabled by default)           |
| `-n, --(no-)normalized-dir`    | Create/skip normalized directory (enabled by default)         |
| `-i, --input-format <format>`  | Input audio format: `mp3` / `flac` (default: `mp3`)           |
| `-o, --output-format <format>` | Output audio format (**MP3 only**, default: `mp3`)            |
| `-h, --help`                   | Show help message and exit                                    |

## Critical Limitations & Usage Rules

1. **Audio Format Restrictions**
   - Input: Only `mp3` and `flac` are supported
   - Output: **Only `mp3` is supported** (tagging exclusively works with MP3 files)
2. **URL Requirements**
   - All URLs must follow `curl` syntax, e.g. spaces should be encoded as `%20`
3. **Local File Input**
   - If input files not exists, the script treats them as URLs

## Installation

```bash
sudo make install
```

**Make Parameters**

- `PREFIX`: Installation prefix (default: `/usr/local`)
- `DESTDIR`: Destination directory for installation (default: `""`)

## Examples

### Basic Download (Music + Lyrics)

```bash
save-music https://example.com/track.mp3 https://example.com/lyrics.lrc \
  -t "My Track" -a "Artist Name"
```

**Output Files**

- `original/My Track - Artist Name.{mp3,lrc}` (unmodified files)
- `normalized/My Track - Artist Name.{mp3,lrc}` (normalized audio with ID3 tags)

### FLAC Input → MP3 Output (with Tagging)

```bash
save-music https://example.com/audio%20with%20space.flac -i flac -t "Sample" -a "Performer"
```

**Output Files**

- `original/Sample - Performer.flac` (unmodified FLAC file)
- `normalized/Sample - Performer.mp3` (normalized MP3 with ID3 tags)

### Local File Input

```bash
save-music ~/music/song.flac -i flac -t "Title" -a "Artist"
```

### Disable Original Directory

```bash
save-music https://example.com/song.mp3 --no-original-dir -t "Title" -a "Artist"
```
