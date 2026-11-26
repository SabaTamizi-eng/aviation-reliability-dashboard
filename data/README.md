# Data

## Service Difficulty Reports (FAA)

Operators, repair stations and mechanics in the US file a Service Difficulty Report
(SDR) when they find a failure, malfunction or defect on an aircraft (14 CFR 121.703,
125.409, 135.415, 145.221). The FAA publishes every report as one CSV file per year:

- Download page: https://www.faa.gov/av-info/download_SDR
- File URL: `https://external.apic4e.faa.gov/sdrs/retrieve/SDR-<year>.csv`
- Field definitions: [SDRS Batch File Layout](https://sdrs.faa.gov/Documents/Batch%20File%20Layout.pdf)

The report uses 2021-2025 (five full years, 323,671 reports, about 33 MB per year).
The raw files are not committed. Power BI reads them straight from the FAA site, or from
`data/raw/` after running `download_sdr.ps1`.

An SDR describes what was found, not how often aircraft fly, so counts reflect fleet
size and reporting practice as well as reliability. The report compares shares and
mixes (for example, the share of findings that are corrosion) rather than ranking
operators.

## Reference tables (`reference/`)

| File | Source |
|---|---|
| `jasc_codes.csv` | [FAA JASC code table](https://sdrs.faa.gov/documents/JASC_Code.pdf): code, system title, chapter |
| `stage_of_operation.csv`, `how_discovered.csv`, `nature_of_condition.csv`, `precautionary_procedure.csv`, `submitter_type.csv` | [SDRS look-up tables](https://sdrs.faa.gov/Documents/SDRS%20Look-Up%20Tables.zip), with groupings added |
| `part_conditions.csv` | SDRS part condition list, mapped to finding categories |
| `aircraft_models.csv` | SDRS aircraft make/model list |
| `aircraft_makes.csv`, `aircraft_families.csv`, `engine_makes.csv` | manufacturer names and family rules, written for this project |

The code descriptions are the FAA's, tidied to sentence case. The groupings (phase of
flight, discovery method, finding categories, aircraft families and categories) are
my own and are documented in [docs/data_model.md](../docs/data_model.md).
