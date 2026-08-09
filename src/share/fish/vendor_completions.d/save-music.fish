complete -c save-music -l title -s t -d Title -r
complete -c save-music -l artist -s a -d Artist -r

complete -c save-music -l original-dir-path \
    -d "Directory storing original files (default: original)" -r
complete -c save-music -l normalized-dir-path \
    -d "Directory storing normalized files (default: normalized)" -r

complete -c save-music -l original-dir -s O -d "Create original-dir-path (on by default)"
complete -c save-music -l no-original-dir -d "Do not create original-dir-path"

complete -c save-music -l normalized-dir -s n -d "Create normalized-dir-path (on by default)"
complete -c save-music -l no-normalized-dir -d "Do not create normalized-dir-path"

complete -c save-music -l output-format -s o \
    -d "Output format (default: mp3, 'same' keeps input format)" \
    -ra "mp3 flac same"

complete -c save-music -l help -s h -d "Prints help"
