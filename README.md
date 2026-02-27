# Video Date Fix – ExifTool Scripts

Sets the recording date in MP4 videos based on the filename.  
Designed for old Mini-DV videos captured with WinDV that have no date in their metadata.

---

## Windows – `fix_dates.ps1`

### Requirements

- Download [ExifTool for Windows](https://exiftool.org) and extract it
- You might need to Rename `exiftool(-k).exe` to `exiftool.exe`
- Adjust the path to `exiftool.exe` in the script

### How to run

```powershell
.\fix_dates.ps1
```

If you get an "Execution Policy" Error you also need to run 
```PowerShell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned  # one-time setup
```
### 
What to adjust

| Line              | What to change                                                    |
| ----------------- | ----------------------------------------------------------------- |
| `$exiftool = ...` | Path to exiftool.exe                                              |
| `"F:\*.mp4"`      | Drive letter of your external drive with Videos or Path to Videos |

---

## Mac – `fix_dates.sh`

### Requirements

```bash
brew install exiftool
```

### How to run

```bash
chmod +x fix_dates.sh
./fix_dates.sh
```

### What to adjust

| Line                  | What to change                                                                         |
| --------------------- | -------------------------------------------------------------------------------------- |
| `/Volumes/DRIVENAME/` | Name of your drive (visible in Finder under "Locations") or Path direct Path to videos |

---

## Linux – `fix_dates.sh`

### Requirements

```bash
sudo apt install exiftool
```

### What to adjust

|Line|What to change|
|---|---|
|`/mnt/f/`|Mount point of your external drive|

---

## Why the detour via /tmp?

ExifTool cannot create temporary files directly on external drives (permission issue on NTFS/exFAT). Therefore each file is briefly copied to the internal drive, processed there, and then copied back. The temp folder is automatically deleted at the end.

## What gets written?

The following metadata tags are extracted from the filename and written into the video:

- `CreateDate`
- `ModifyDate`
- `TrackCreateDate`
- `MediaCreateDate`

Apple Photos uses these tags to sort videos chronologically by recording date.# Video Datum Fix – ExifTool Skripte

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
