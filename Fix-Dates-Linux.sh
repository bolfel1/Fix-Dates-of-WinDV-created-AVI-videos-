#!/bin/bash
EXIFTOOL="exiftool"
TMPDIR_CUSTOM="/tmp/exiftool_tmp"
mkdir -p "$TMPDIR_CUSTOM"

for f in /mnt/f/*.mp4; do
    # ._-Dateien überspringen
    basename=$(basename "$f")
    if [[ "$basename" == ._* ]]; then
        continue
    fi
    
    # Nach /tmp kopieren
    tmpfile="$TMPDIR_CUSTOM/$basename"
    cp "$f" "$tmpfile"
    
    # Datum setzen
    $EXIFTOOL -api QuickTimeUTC=1 \
        '-CreateDate<${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20$1:$2:$3 $4:$5:00/}' \
        '-ModifyDate<${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20$1:$2:$3 $4:$5:00/}' \
        '-TrackCreateDate<${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20$1:$2:$3 $4:$5:00/}' \
        '-MediaCreateDate<${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20$1:$2:$3 $4:$5:00/}' \
        -overwrite_original \
        "$tmpfile"
    
    # Zurückkopieren und löschen
    cp "$tmpfile" "$f"
    rm "$tmpfile"
    
    echo "Fertig: $basename"
done

# Aufräumen
rm -rf "$TMPDIR_CUSTOM"
echo "Alle Videos fertig!"
