# Downloads the FAA Service Difficulty Report files into data\raw, for Power BI's Folder mode.
# Not needed in Web mode, where Power BI reads the same files straight from the FAA site.
#
#   powershell -ExecutionPolicy Bypass -File data\download_sdr.ps1 -FirstYear 2021 -LastYear 2025

param([int]$FirstYear = 2021, [int]$LastYear = 2025)

$raw = Join-Path $PSScriptRoot "raw"
New-Item -ItemType Directory -Force $raw | Out-Null

foreach ($year in $FirstYear..$LastYear) {
    $file = Join-Path $raw "SDR-$year.csv"
    $url = "https://external.apic4e.faa.gov/sdrs/retrieve/SDR-$year.csv"
    Write-Host "Downloading $url"
    Invoke-WebRequest -Uri $url -OutFile $file -UseBasicParsing
    Write-Host ("  {0:N1} MB" -f ((Get-Item $file).Length / 1MB))
}
