# Video Datum Fix – ExifTool Skripte

Setzt das Aufnahmedatum in MP4-Videos anhand des Dateinamens.  
Gedacht für alte Mini-DV Videos die mit WinDV aufgenommen wurden und kein Datum in den Metadaten haben.

## Voraussetzung

Die Dateinamen müssen folgendes Format haben:
```
all.YY-MM-DD_HH-MM.SS.mp4
1.YY-MM-DD_HH-MM.SS.mp4
```
Beispiel: `all.06-07-21_17-06.00.mp4` → wird zu `2006-07-21 17:06`

---

## Windows – `fix_dates.ps1`

### Voraussetzung
- [ExifTool für Windows](https://exiftool.org) herunterladen und entpacken
- Pfad zu `exiftool.exe` im Skript anpassen

### Skript
```powershell
$exiftool = "C:\Users\maxbo\Downloads\exiftool-13.51_64\exiftool-13.51_64\exiftool.exe"
$tmpDir = "C:\exiftool_tmp"

New-Item -ItemType Directory -Force -Path $tmpDir

Get-ChildItem "F:\*.mp4" | Where-Object { $_.Name -notlike "._*" } | ForEach-Object {
    $original = $_.FullName
    $tmpFile = Join-Path $tmpDir $_.Name

    Copy-Item $original $tmpFile

    & $exiftool -api QuickTimeUTC=1 `
        "-CreateDate<`${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20`$1:`$2:`$3 `$4:`$5:00/}" `
        "-ModifyDate<`${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20`$1:`$2:`$3 `$4:`$5:00/}" `
        "-TrackCreateDate<`${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20`$1:`$2:`$3 `$4:`$5:00/}" `
        "-MediaCreateDate<`${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20`$1:`$2:`$3 `$4:`$5:00/}" `
        -overwrite_original `
        $tmpFile

    Copy-Item $tmpFile $original -Force
    Remove-Item $tmpFile

    Write-Host "Fertig: $($_.Name)"
}

Remove-Item $tmpDir -Recurse
Write-Host "Alle Videos fertig!"
```

### Ausführen
```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned  # einmalig
.\fix_dates.ps1
```

### Anpassen
| Zeile | Was ändern |
|-------|-----------|
| `$exiftool = ...` | Pfad zur exiftool.exe |
| `"F:\*.mp4"` | Laufwerksbuchstabe der Festplatte |

---

## Mac – `fix_dates.sh`

### Voraussetzung
```bash
brew install exiftool
```

### Skript
```bash
#!/bin/bash
EXIFTOOL="exiftool"
TMPDIR_CUSTOM="/tmp/exiftool_tmp"
mkdir -p "$TMPDIR_CUSTOM"

for f in /Volumes/FESTPLATTENNAME/*.mp4; do
    basename=$(basename "$f")
    if [[ "$basename" == ._* ]]; then
        continue
    fi

    tmpfile="$TMPDIR_CUSTOM/$basename"
    cp "$f" "$tmpfile"

    $EXIFTOOL -api QuickTimeUTC=1 \
        '-CreateDate<${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20$1:$2:$3 $4:$5:00/}' \
        '-ModifyDate<${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20$1:$2:$3 $4:$5:00/}' \
        '-TrackCreateDate<${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20$1:$2:$3 $4:$5:00/}' \
        '-MediaCreateDate<${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20$1:$2:$3 $4:$5:00/}' \
        -overwrite_original \
        "$tmpfile"

    cp "$tmpfile" "$f"
    rm "$tmpfile"

    echo "Fertig: $basename"
done

rm -rf "$TMPDIR_CUSTOM"
echo "Alle Videos fertig!"
```

### Ausführen
```bash
chmod +x fix_dates.sh
./fix_dates.sh
```

### Anpassen
| Zeile | Was ändern |
|-------|-----------|
| `/Volumes/FESTPLATTENNAME/` | Name der Festplatte (sichtbar im Finder unter „Orte") |

---

## Linux – `fix_dates.sh`

Identisch mit Mac, nur der Pfad zur Festplatte ist anders.

### Voraussetzung
```bash
sudo apt install exiftool   # Ubuntu/Debian
sudo dnf install exiftool   # Fedora
```

### Anpassen
| Zeile | Was ändern |
|-------|-----------|
| `/mnt/f/` | Einhängepunkt der Festplatte |

---

## Warum der Umweg über /tmp ?

ExifTool kann Temp-Dateien nicht direkt auf externen Laufwerken erstellen (Berechtigungsproblem). Deshalb wird jede Datei kurz auf das interne Laufwerk kopiert, dort bearbeitet und dann zurückkopiert.

## Was wird gesetzt?

Folgende Metadaten-Tags werden aus dem Dateinamen extrahiert und geschrieben:

- `CreateDate`
- `ModifyDate`  
- `TrackCreateDate`
- `MediaCreateDate`

Apple Photos nutzt diese Tags um Videos chronologisch zu sortieren.
