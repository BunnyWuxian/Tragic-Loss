# tragic-loss

A personal carry-over tool for protecting what I've created before a reinstall or hardware swap.

## v0.1: Wallpaper Engine project finder
Searches C:\Windows.old, D:\, and E:\ for Wallpaper Engine projects by looking for
`project.json` files with a scene, video, web, or application type, and lists them newest first.

**Read-only.** It never changes, moves, or deletes anything.
**Surface-level search.** It finds files that still exist. It does not recover deleted files *yet*.

## Why I built this
I lost unfinished Wallpaper Engine projects and my Obsidian vault in a Windows reinstall.
Windows' backup saved things I didn't care about and missed the things I made.
Then the curiosity got the best of me, and it turned into a dive into how NTFS
actually stores (and forgets) files.

## How to run
1. Open PowerShell as Administrator.
2. Run the script.
3. Results show the project path and last-modified time.

## Roadmap
- Board-swap mode: pick what to carry over (projects, Adobe brushes, Obsidian vault) and copy it to a USB
- Save and restore boot entries after a motherboard swap
- Future: MFT scanner for forensic recovery of deleted files (and a rename to bunny-burrow)
