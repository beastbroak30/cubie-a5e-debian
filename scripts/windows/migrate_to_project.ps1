$ErrorActionPreference = 'Stop'
$src = 'C:\Users\akant\AppData\Local\Temp\opencode'
$dst = 'D:\misc_prj\radxa_firmware'

$deny = '^(kanre|izo-client|ruview|nvidia-|cloudflare-|hallmark-review)' +
        '|(kicad|probe_|_probe|sch_|pcb|drc_|lcsc|find_soic|find_max31865|find_pinout|check_lm35|tl431|symcheck|padcheck|scan_pdf|verify_vals|parse_s1|parse_s2|render_review|shrink_servo|migrate_figdata|zip_top|pick[0-9]|^p14\.py|^sec9\.py|cut_must|chk_fig6|docs_ws|build_ws|patch_collect|audit_clash|mcp_|test_lite|test_fetch|test\.pdf|fetch_robu|check_ds|parse_pdf|scaf|schemtest|simmodels|_pdffig|_chipprobe|_sympins|_labelcombos|layout_prompt|visual_prompt|set_visual_prompt|set_agent_prompt|remove_visual|package\.json|profile[0-9])' +
        '|^(__pycache__|venv|node_modules|images|refs|new|final|film|intro|logo|ds|dx9|stm32|aria2test|tmp|migrate_to_project\.ps1)$' +
        '|^AGENTS\.md$'

$dirs = @('docs', 'docs\manifest', 'scripts\build', 'scripts\board', 'scripts\windows', 'scripts\misc', 'logs', 'tools', 'tools\bin', 'tools\firmware')
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path (Join-Path $dst $d) | Out-Null }
$logPath = Join-Path $dst 'docs\MOVE-LOG.txt'
if (-not (Test-Path $logPath)) { New-Item -ItemType File -Path $logPath | Out-Null }

$moved = 0
$kept = New-Object System.Collections.ArrayList

function Move-One {
    param([string]$full, [string]$name, [string]$sub)
    $dir = Join-Path $dst $sub
    $target = Join-Path $dir $name
    if (Test-Path -LiteralPath $target) { $target = Join-Path $dir ('dup-' + $name) }
    Move-Item -LiteralPath $full -Destination $target
    "$name -> $sub\" | Out-File -Append -FilePath $logPath -Encoding utf8
    $script:moved++
}

foreach ($item in (Get-ChildItem -LiteralPath $src -Force)) {
    $n = $item.Name
    if ($n -match $deny) { [void]$kept.Add($n); continue }

    if ($item.PSIsContainer) {
        if ($n -eq 'aic8800d80') { Move-One $item.FullName $n 'tools\firmware'; continue }
        if ($n -eq 'cubie-manifest') { Move-One $item.FullName $n 'docs\manifest'; continue }
        if ($n -eq 'repo') {
            foreach ($f in (Get-ChildItem -LiteralPath $item.FullName -Recurse -File)) {
                $rel = $f.FullName.Substring($item.FullName.Length).TrimStart('\')
                $t = Join-Path $dst $rel
                New-Item -ItemType Directory -Force -Path (Split-Path -Parent $t) | Out-Null
                Copy-Item -LiteralPath $f.FullName -Destination $t -Force
                "repo\$rel -> $rel" | Out-File -Append -FilePath $logPath -Encoding utf8
            }
            Remove-Item -LiteralPath $item.FullName -Recurse -Force
            $moved++
            continue
        }
        [void]$kept.Add($n); continue
    }

    if ($n -match '\.log$')                     { Move-One $item.FullName $n 'logs'; continue }
    if ($n -match '^cubie-.*\.tar\.gz$')        { Move-One $item.FullName $n 'docs\manifest'; continue }
    if ($n -eq 'bt_test')                       { Move-One $item.FullName $n 'tools\bin'; continue }
    if ($n -match '\.ps1$')                     { Move-One $item.FullName $n 'scripts\windows'; continue }
    if ($n -match '^([0-9]{2}|1x)-.*\.sh$')     { Move-One $item.FullName $n 'scripts\build'; continue }
    if ($n -match '\.sh$')                      { Move-One $item.FullName $n 'scripts\board'; continue }
    if ($n -match '\.(py|js|cjs|mjs|txt|json)$'){ Move-One $item.FullName $n 'scripts\misc'; continue }
    [void]$kept.Add($n)
}

"" | Out-File -Append -FilePath $logPath -Encoding utf8
"=== moved: $moved, untouched: $($kept.Count) ===" | Out-File -Append -FilePath $logPath -Encoding utf8
"untouched: $($kept -join ', ')" | Out-File -Append -FilePath $logPath -Encoding utf8
Write-Host "moved=$moved untouched=$($kept.Count)"
Write-Host ("untouched: " + ($kept -join ', '))
