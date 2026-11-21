$path = "C:\Users\akant\.config\opencode\opencode.jsonc"
$j = Get-Content $path -Raw

$add = '\n\nPERSISTENT MEMORY (basic-memory MCP, project \"kanre\")\n- Before non-trivial work, read the project notes: bm_search(project=\"kanre\", query=...) or bm_read on kanre/00-project-state.md, 01-decisions.md, 02-verified-parts.md, 03-nucleo-g491re-pinmap.md, 04-gotchas.md. They hold approved decisions, verified parts, the Nucleo header map, and traps that already cost time.\n- After you decide anything that changes a value, part, pin or topology, append it with bm_edit(project=\"kanre\", identifier=..., command=\"append\", content=...). Do not rewrite notes.\n- The file artifacts stay authoritative for machine data. If a note disagrees with a file, the file wins and you correct the note.\n- context7 is for library and SDK documentation only. It is never a source for a pin number.'

$agents = @('"kicad-architect"','"kicad-ingestor"','"kicad-ingestor-backup"','"kicad-layout"','"kicad-procurement"')
$count = 0

foreach ($a in $agents) {
    $idx = $j.IndexOf($a)
    if ($idx -lt 0) { Write-Output "MISS agent $a"; continue }

    $sysIdx = $j.IndexOf('"system": "', $idx)
    if ($sysIdx -lt 0) { Write-Output "MISS system $a"; continue }

    $start = $sysIdx + '"system": "'.Length

    # walk to the closing unescaped quote
    $i = $start
    $end = -1
    while ($i -lt $j.Length) {
        $ch = $j[$i]
        if ($ch -eq '\') { $i += 2; continue }
        if ($ch -eq '"') { $end = $i; break }
        $i++
    }
    if ($end -lt 0) { Write-Output "MISS close $a"; continue }

    if ($j.Substring($start, $end - $start) -match 'PERSISTENT MEMORY') {
        Write-Output "SKIP already $a"
        continue
    }

    $j = $j.Substring(0, $end) + $add + $j.Substring($end)
    $count++
    Write-Output "OK $a"
}

if ($count -gt 0) {
    Copy-Item $path "$path.bak-memory" -Force
    Set-Content -Path $path -Value $j -NoNewline -Encoding UTF8
    Write-Output "written, backup at $path.bak-memory"
}
