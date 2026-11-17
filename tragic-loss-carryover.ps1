& {
$found = @()

# Wallpaper Engine: ask Steam where its libraries are
$steamVdf = "${env:ProgramFiles(x86)}\Steam\steamapps\libraryfolders.vdf"
if (Test-Path -LiteralPath $steamVdf) {
    $libs = Select-String -LiteralPath $steamVdf -Pattern '"path"\s+"(.+?)"' |
        ForEach-Object { $_.Matches[0].Groups[1].Value -replace '\\\\', '\' }
    foreach ($lib in $libs) {
        $we = Join-Path $lib 'steamapps\common\wallpaper_engine\projects\myprojects'
        if (Test-Path -LiteralPath $we) {
            $found += [pscustomobject]@{ App = 'Wallpaper Engine'; What = 'My projects'; Path = $we }
        }
    }
}

# Obsidian: ask Obsidian where its vaults are
$obsJson = "$env:APPDATA\obsidian\obsidian.json"
if (Test-Path -LiteralPath $obsJson) {
    $cfg = Get-Content -LiteralPath $obsJson -Raw | ConvertFrom-Json
    foreach ($v in $cfg.vaults.PSObject.Properties) {
        if (Test-Path -LiteralPath $v.Value.path) {
            $found += [pscustomobject]@{ App = 'Obsidian'; What = 'Vault'; Path = $v.Value.path }
        }
    }
}

if ($found.Count -eq 0) { Write-Host 'Nothing found to carry over yet.'; return }

# You choose. Nothing is saved unless you pick it.
$picked = @($found | Out-GridView -Title 'tragic-loss: pick what to save (Ctrl+click for more), then OK' -PassThru)
if ($picked.Count -eq 0) { Write-Host 'Nothing selected. Nothing was saved.'; return }

# Size check: how big is this save, and is there room for it?
$total = 0
foreach ($p in $picked) {
    $total += (Get-ChildItem -LiteralPath $p.Path -Recurse -File -Force -ErrorAction SilentlyContinue |
        Measure-Object Length -Sum).Sum
}
$desktop = [Environment]::GetFolderPath('Desktop')
$drive = (Get-Item -LiteralPath $desktop).PSDrive
$free = $drive.Free
Write-Host ''
Write-Host ("You picked {0} item(s), about {1:N1} GB." -f $picked.Count, ($total / 1GB))
Write-Host ("Free space on {0}: {1:N1} GB." -f $drive.Name, ($free / 1GB))
if ($total -ge $free) { Write-Host 'Not enough space to save this. Nothing was saved.'; return }

# How do you want it packed?
Write-Host ''
Write-Host 'How do you want it packed?'
Write-Host '  1) One zip (default)'
Write-Host '  2) One zip per app'
Write-Host '  3) Plain folder, no zip (fastest to open)'
$mode = Read-Host 'Choose 1, 2, or 3 (Enter = 1)'
if ($mode -notin '2', '3') { $mode = '1' }

Write-Host 'Bigger saves take longer, so large folders can take a while.'
$answer = Read-Host 'Ready to save? (y/n)'
if ($answer -ne 'y') { Write-Host 'Cancelled. Nothing was saved.'; return }

$stamp = Get-Date -Format 'yyyy-MM-dd_HHmm'
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

# Writes a set of picked items into one zip, then checks its own work
function Save-Zip($items, $zipPath) {
    $files = @(foreach ($p in $items) {
        $root = Split-Path $p.Path -Parent
        Get-ChildItem -LiteralPath $p.Path -Recurse -File -Force -ErrorAction SilentlyContinue |
            ForEach-Object { [pscustomobject]@{ Full = $_.FullName; Entry = ($_.FullName.Substring($root.Length).TrimStart('\') -replace '\\', '/') } }
    })
    $saved = 0; $skipped = @()
    $archive = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
    try {
        foreach ($f in $files) {
            try {
                [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $f.Full, $f.Entry, [System.IO.Compression.CompressionLevel]::NoCompression)
                $saved++
            } catch { $skipped += $f.Full }
            if ($saved % 50 -eq 0) { Write-Progress -Activity "Saving $(Split-Path $zipPath -Leaf)" -Status "$saved of $($files.Count) files" -PercentComplete (100 * $saved / [math]::Max(1, $files.Count)) }
        }
    } finally { $archive.Dispose() }
    Write-Progress -Activity 'Saving' -Completed
    $check = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    $inZip = $check.Entries.Count
    $check.Dispose()
    Write-Host ''
    Write-Host "Saved: $zipPath"
    Write-Host "Files found: $($files.Count)   Files in zip: $inZip"
    if ($skipped.Count -gt 0) {
        Write-Host "Skipped $($skipped.Count) file(s) that couldn't be read (maybe open in another app):"
        $skipped | ForEach-Object { Write-Host "  $_" }
    }
}

switch ($mode) {
    '1' {
        Save-Zip $picked (Join-Path $desktop "tragic-loss-$stamp.zip")
    }
    '2' {
        foreach ($group in ($picked | Group-Object App)) {
            Save-Zip $group.Group (Join-Path $desktop "tragic-loss-$stamp - $($group.Name).zip")
        }
    }
    '3' {
        $outDir = Join-Path $desktop "tragic-loss-$stamp"
        foreach ($p in $picked) {
            $target = Join-Path $outDir "$($p.App) - $(Split-Path $p.Path -Leaf)"
            robocopy $p.Path $target /E /R:1 /W:1 /NFL /NDL /NJH /NJS | Out-Null
            $srcCount = @(Get-ChildItem -LiteralPath $p.Path -Recurse -File -Force -ErrorAction SilentlyContinue).Count
            $dstCount = @(Get-ChildItem -LiteralPath $target -Recurse -File -Force -ErrorAction SilentlyContinue).Count
            Write-Host "$($p.App): files found $srcCount   files copied $dstCount"
        }
        Write-Host "Saved to folder: $outDir"
    }
}
if ($mode -ne '3') {
    Write-Host ''
    Write-Host 'Tip: big zips can take a minute to open. If File Explorer seems stuck, restart it in Task Manager.'
}
}
