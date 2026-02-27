$exiftool = "Path\to\exiftool.exe"
$tmpDir = "C:\exiftool_tmp"

Get-ChildItem "F:\*.mp4" | Where-Object { $_.Name -notlike "._*" } | ForEach-Object {
    $original = $_.FullName
    $tmpFile = Join-Path $tmpDir $_.Name
    
    # Nach C: kopieren
    Copy-Item $original $tmpFile
    
    # Datum setzen
    & $exiftool -api QuickTimeUTC=1 `
        "-CreateDate<`${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20`$1:`$2:`$3 `$4:`$5:00/}" `
        "-ModifyDate<`${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20`$1:`$2:`$3 `$4:`$5:00/}" `
        "-TrackCreateDate<`${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20`$1:`$2:`$3 `$4:`$5:00/}" `
        "-MediaCreateDate<`${filename;s/.*(\d{2})-(\d{2})-(\d{2})_(\d{2})-(\d{2})\.\d{2}.*/20`$1:`$2:`$3 `$4:`$5:00/}" `
        -overwrite_original `
        $tmpFile
    
    # Zurückkopieren und löschen
    Copy-Item $tmpFile $original -Force
    Remove-Item $tmpFile
    Remove-Item "C:\exiftool_tmp" -Recurse
    
    Write-Host "Fertig: $($_.Name)"
}
