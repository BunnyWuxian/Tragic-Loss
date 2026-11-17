# tragic-loss

A personal carry-over tool for protecting what I've created before a reinstall or hardware swap.

## v0.1: Wallpaper Engine project finder
Searches C:\Windows.old, D:\, and E:\ for Wallpaper Engine projects by looking for
`project.json` files with a scene, video, web, or application type, and lists them newest first.

**Read-only.** It never changes, moves, or deletes anything.
**Surface-level search.** It finds files that still exist. It does not recover deleted files *yet*.

## v0.2: Carry-over mode (`tragic-loss-carryover.ps1`)
Finds your Wallpaper Engine projects (by reading Steam's own library list,
so custom install locations work) and your Obsidian vaults (from Obsidian's
own settings). You pick what to save, it checks the size against your free
space, asks how to pack it, asks before starting, then saves to your Desktop.

**Packing options:** one zip (default), one zip per app, or a plain folder.

- Fast "store" mode: no compression, since images and video barely shrink anyway
- Checks its own work: counts files found vs. files saved
- Lists any file it couldn't read instead of failing silently
- Runs only on your PC, saves nothing without your pick, sends nothing anywhere

## Known quirks
- Big zips can take a minute to open in File Explorer. If it seems stuck,
  restart Windows Explorer in Task Manager.

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
- My own window (v0.3): checkboxes, "…" buttons to open and confirm each folder, paste a path when one isn't found
- More apps: Adobe brushes and presets, and others
- Save and restore boot entries after a motherboard swap
- Future: MFT scanner for forensic recovery of deleted files (and a rename to bunny-burrow)
