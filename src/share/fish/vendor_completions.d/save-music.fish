complete -c save-music -l title -s t -d Title -r
complete -c save-music -l artist -s a -d Artist -r

complete -c save-music -l original-dir -s o \
    -d 'Dreictory storing original files (default: original)'
complete -c save-music -l normalized-dir -s n \
    -d 'Directory storing normalized files (default: normalized)'

complete -c save-music -l input-format -s i \
    -d 'Input format (default: mp3)' \
    -r -a 'mp3 flac'
complete -c save-music -l output-format -s O \
    -d 'Output format (default: mp3)' \
    -r -a 'mp3 flac'
