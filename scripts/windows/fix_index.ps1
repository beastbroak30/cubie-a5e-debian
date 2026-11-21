$path = "D:\KANRE\kicad\artifacts\datasheets\index.json"
$j = Get-Content $path -Raw | ConvertFrom-Json

function New-Entry {
    param($mpn, $package, $source, $pdf, $md, $ref, $pages, $status, $reason)
    return [ordered]@{
        mpn         = $mpn
        package     = $package
        source_url  = $source
        local_pdf   = $pdf
        local_md    = $md
        local_ref   = $ref
        page_count  = $pages
        status      = $status
        reason      = $reason
    }
}

# 1. Nucleo manual, re-extracted and now authoritative for the carrier pad map.
$j.parts | Add-Member -NotePropertyName "NUCLEO-G491RE-UM2505" -NotePropertyValue (New-Entry `
    "NUCLEO-G491RE" `
    "MB1367 board, 2x19 morpho plus four Arduino female headers" `
    "https://docs.rs-online.com/f752/A700000007388221.pdf" `
    "none (extracted from the remote PDF directly)" `
    "artifacts/datasheets/NUCLEO-G491RE-UM2505.md" `
    "artifacts/datasheets/NUCLEO-G491RE-UM2505.ref.md" `
    43 `
    "OK" `
    "Rev 3, November 2020. Re-extracted pages 28-40 to recover Table 16 in full; the earlier 4.5 kB extract carried only the even row of CN7 and no CN10 table at all, which left seven MCU pads unresolvable. All twelve signals plus AGND and VREFP now verified.") -Force

# 2. The chosen C7 capacitor. Honest status: the sheet on disk is the
#    automotive sibling, not the exact ordering code.
$j.parts | Add-Member -NotePropertyName "GRM21B5C1H223JA01L" -NotePropertyValue (New-Entry `
    "GRM21B5C1H223JA01L" `
    "0805, 22 nF, 50 V, C0G, 5 percent" `
    $null `
    "none" `
    "artifacts/datasheets/GRM21B5C1H223JA01L.md" `
    "none" `
    $null `
    "PARTIAL" `
    "The file on disk is the muRata GCM21B5C1H223JA16 automotive specification sheet, the same 22000 pF / 50 V / C0G construction under the AEC-Q200 control code, not the exact commercial ordering code. The C0G insulation table used for the leakage calculation (line 112, 1000 ohm-farad at 25 C; line 113, 100 ohm-farad at 125 C) is a family specification and is expected to hold, but the exact part's own sheet was not obtained: murata.com refuses automated fetching (robots.txt returns 403) and the LCSC datasheet mirror URL was not recorded. Obtain the approval sheet for the ordering code before the leakage figure is treated as final.") -Force

# 3. Rejected candidate, kept as a record of why.
$j.parts | Add-Member -NotePropertyName "ECHU1H104JX9" -NotePropertyValue (New-Entry `
    "ECHU1H104JX9" `
    "PPS film, 4.8 x 3.3 x 2.1 mm (ECHU size E2)" `
    "artifacts/C569829 LCSC listing, page fetched by procurement" `
    "artifacts/ECHU1H104JX9_ds.pdf" `
    "artifacts/datasheets/ECHU1H104JX9.md" `
    "none" `
    $null `
    "REJECTED" `
    "Sourced as the film-capacitor answer to the C7 leakage budget, then rejected on its own numbers: insulation resistance is a flat 3000 Mohm at 50 V DC, which is 5.58 nA at 16.75 V against a 1 nA requirement. Worse than the ceramic it was meant to replace. Kept on disk as the evidence for that decision.") -Force

# 4. Rejected 0.1 uF C0G candidate.
$j.parts | Add-Member -NotePropertyName "GRM3195C2A104GA01D" -NotePropertyValue (New-Entry `
    "GRM3195C2A104GA01D" `
    "1206, 0.1 uF, 100 V, C0G" `
    $null `
    "artifacts/GRM3195C2A104GA01D_ds.pdf" `
    "artifacts/datasheets/GRM3195C2A104GA01D.md" `
    "none" `
    $null `
    "REJECTED" `
    "0.1 uF C0G considered for C7 and rejected on leakage: 3.35 nA worst case at the node voltage, over the 1 nA requirement. Leakage is proportional to capacitance, so the value was reduced to 22 nF rather than the dielectric changed.") -Force

$j | Add-Member -NotePropertyName "notes" -NotePropertyValue @(
    "One entry per MPN the design actually uses, plus entries for parts considered and rejected, because the reason for rejection is design data.",
    "status values: OK means the named part's own datasheet was converted and the pin or value table came out clean. PARTIAL means the conversion is usable but the document is not the exact ordering code, or a page failed. REJECTED means the part was evaluated and dropped, with the reason recorded.",
    "A pin or value without an entry here is not verified and does not belong in the netlist or the BOM."
) -Force

$j | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
"written"
$check = Get-Content $path -Raw | ConvertFrom-Json
"entries: " + ($check.parts.PSObject.Properties.Name).Count
$check.parts.PSObject.Properties | ForEach-Object { "  $($_.Name): $($_.Value.status)" }
