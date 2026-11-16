# save-music

Download or copy a single track and its LRC lyrics, optionally normalize the audio, and optionally tag the result.

`save-music` is a thin Bash wrapper around `curl`, `ffmpeg` and `kid3-cli`. Give it one music source and an optional lyrics source; it fetches both, detects the audio format, converts it when necessary, normalizes it through `ffmpeg-normalize`, and writes title/artist tags with `kid3-cli`. Each stage can be skipped. With the default flags it keeps an untouched copy in `original/` and a normalized, tagged copy in `normalized/`.

The installed CLI is generated at build time from an argbash template, so `make` is needed even if you only want to run the script from a checkout.

## Requirements

Runtime:

- `bash`
- `curl` — downloads music and lyrics
- `ffmpeg` — `ffprobe` detects the audio codec and `ffmpeg` performs conversion
- `ffmpeg-normalize` — invoked by the `mp3-normalize` and `flac-normalize` helpers
- `kid3-cli` — writes the title and artist tags

On startup the script checks for `curl`, `ffmpeg`, `kid3-cli`, `mp3-normalize` and `flac-normalize` and exits with an error if any of them is missing.

Build:

- `make`
- `pkg-config` — checked by `make check`, and used to locate the fish completion directory
- `argbash` — or the vendored submodule at `build/argbash`

Optional:

- `fish` — only needed to use the shipped completion script

## Installation

```bash
git submodule update --init     # populate build/argbash (skip if argbash is already installed)
make                            # generate build/save-music
sudo make install               # install the executables and fish completion
```

`make` generates `build/save-music` from [save-music.tmpl.bash](src/templates/argbash/save-music.tmpl.bash) using `argbash` and marks it executable. The `ARGBASH` variable defaults to `argbash` from `PATH` and falls back to `build/argbash/bin/argbash`.

`make install` installs, relative to `PREFIX` (default `/usr/local`):

| Source | Destination |
| --- | --- |
| `build/save-music` | `$(PREFIX)/bin/save-music` |
| `src/bin/mp3-normalize`, `src/bin/flac-normalize` | `$(PREFIX)/bin/` |
| `src/share/fish/vendor_completions.d/save-music.fish` | fish completions directory |

The fish completions directory comes from `pkg-config --variable=completionsdir fish`, falling back to `$(PREFIX)/share/fish/vendor_completions.d`. If pkg-config resolves a system path, `PREFIX` does not relocate that file.

- `PREFIX` — installation prefix (default `/usr/local`)
- `DESTDIR` — staging root prepended to every install path, for packaging; e.g. `make install DESTDIR=/tmp/pkg PREFIX=/usr`
- Unprivileged install: `make install PREFIX="$HOME/.local"`
- `make uninstall` — removes exactly the files listed above, honoring `PREFIX`/`DESTDIR` (it does not build first)
- `make clean` — removes `build/save-music` only; the `build/argbash` submodule is left alone

## Usage

A minimal run that downloads, normalizes and tags a track:

```bash
save-music -t "Song Title" -a "Artist" https://example.com/track.mp3
```

This leaves `original/Song Title - Artist.mp3` and `normalized/Song Title - Artist.mp3` in the current directory. Normalization requires `ffmpeg-normalize` to be installed.

To run the generated script without installing it, the two helper scripts must still be on `PATH`:

```bash
PATH="$PWD/src/bin:$PATH" build/save-music -t "Song Title" -a "Artist" https://example.com/track.mp3
```

Generated synopsis (option order follows the template):

```bash
save-music [-t] [-a] [--original-dir-path] [--normalized-dir-path] \
  [-o] [-O] [-n] [-h] <music-url> [<lrc-url>]
```

| Option | Argument | Default | Description |
| --- | --- | --- | --- |
| `-t, --title` | title | empty | Track title; used in file names and tags |
| `-a, --artist` | artist | empty | Track artist; used in file names and tags |
| `--original-dir-path` | directory | `original` | Directory that receives the untouched source audio and the LRC |
| `--normalized-dir-path` | directory | `normalized` | Directory that receives the normalized and tagged audio |
| `-o, --output-format` | format | `mp3` | `mp3`, `flac`, or `same` (keep the detected input format) |
| `-O, --original-dir` / `--no-original-dir` | — | on | Create `--original-dir-path` and copy files into it |
| `-n, --normalized-dir` / `--no-normalized-dir` | — | on | Normalize into `--normalized-dir-path` and tag the result |
| `<music-url>` | URL or path | — | Required music source |
| `<lrc-url>` | URL or path | empty | Optional lyrics source; copied verbatim |
| `-h, --help` | — | — | Print help and exit |

## Configuration

There is no configuration file and no environment variable is read at runtime. Everything is set per invocation with the options above.

Build-time variables in the [Makefile](Makefile): `PREFIX`, `DESTDIR`, `ARGBASH`, and `FISH_COMP_DIR`. The default output directories are relative paths, so they resolve against the current working directory of each run.

## How it works

1. The track name is built as `"<title> - <artist>"`, and a temporary work directory is created with `mktemp -d`.
2. Each source is fetched: an existing regular file is copied with `cp`; anything else is passed to `curl` with a Firefox user agent, `--fail`, `--create-dirs` and `--progress-bar`.
3. `ffprobe` reports the codec of the first audio stream. Only `mp3` and `flac` are accepted; the file is then renamed to `<name>.<input-fmt>`, so the source URL or extension does not matter.
4. `-o same` resolves the output format to the detected input format.
5. If input and output formats differ, `ffmpeg -q 0 -c:v copy` transcodes the file.
6. If normalization is enabled, the matching helper is called with `--output-folder`: it wraps `ffmpeg-normalize` with a target of `-18` LUFS, a true peak of `-1` dBTP, `-lrt 50`, `-ar 44100`, and either MP3 or FLAC output.
7. If the expected normalized file exists, `kid3-cli` sets `title` and `artist` on it. Only the normalized file is tagged.
8. If `--original-dir` is on, the pre-conversion file (still in its input format) is copied with `cp -n`. The LRC is copied with `cp -n` into the original and/or normalized directory, depending on which are enabled.

## Limitations

- Input must be MP3 or FLAC; every other codec aborts with an error. `-o` accepts `mp3`, `flac` and `same`, while other values are not rejected by the parser even though only those three cases are handled.
- A music or lyrics argument that is not an existing regular file is handed to `curl` unchanged, so it must be a URL curl understands and special characters must be encoded (for example a space as `%20`). A mistyped local path is silently treated as a URL.
- `-t` and `-a` are optional flags, but they define the file names and the tags. Passing neither leaves the name as `" - "`.
- Nothing is tagged when normalization is disabled (`--no-normalized-dir`), because tagging only touches the normalized output.
- Title and artist are interpolated into paths verbatim; a `/` in either breaks the directory layout, and a `'` breaks the single-quoted `kid3-cli` expression.
- If normalization does not produce exactly `<normalized-dir>/<name>.<format>`, the tagging step skips silently.
- `cp -n` never overwrites existing originals or LRC files. Overwrite behavior for normalized output is left to `ffmpeg-normalize`.
- Files are archived last: normalization and tagging run before anything is copied into `--original-dir-path`, so a failure there aborts the run with nothing archived.
- One track per run, no playlists or batch mode, and no retry logic: a failed download aborts the run.

## License

MIT. See [LICENSE](LICENSE).
