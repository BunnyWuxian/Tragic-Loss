& {
Clear-Host
$roots = 'C:\Windows.old', 'D:\', 'E:\'
$i = 0
$found = @(Get-ChildItem -Path $roots -Recurse -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $i++
    if ($i % 500 -eq 0) { Write-Progress -Activity 'Searching for Wallpaper Engine projects' -Status "$i folders checked: $($_.FullName)" }
    $p = Join-Path $_.FullName 'project.json'
    if (Test-Path -LiteralPath $p) {
        $text = Get-Content -LiteralPath $p -Raw -ErrorAction SilentlyContinue
        if ($text -match '"type"\s*:\s*"(scene|video|web|application)"') { Get-Item -LiteralPath $p }
    }
})
Write-Progress -Activity 'Searching for Wallpaper Engine projects' -Completed
Write-Host ""
Write-Host "Searched $i folders."
if ($found.Count -eq 0) { Write-Host "Sorry =( we didn't find anything" } else {
    Write-Host "We found something!! =D"
    $found | Sort-Object LastWriteTime -Descending | Format-Table FullName, LastWriteTime -AutoSize }
}
