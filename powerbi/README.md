# Power BI

`AviationReliability.pbip` is a Power BI Project: the semantic model is stored as TMDL
(`AviationReliability.SemanticModel/`) and the report as PBIR (`AviationReliability.Report/`),
so both can be reviewed in Git. `measures.dax` and `power_query/` are readable copies of
the DAX and M code.

## Parameters

| Parameter | Default | Use |
|---|---|---|
| `SourceMode` | `Folder` | `Folder` reads `DataFolder`; `Web` reads the FAA files and the reference tables over HTTPS |
| `DataFolder` | placeholder | the repository's `data\` folder (run `data\download_sdr.ps1` first) |
| `ReferenceUrl` | this repository's `data/reference/` on GitHub | where Web mode reads the lookup files |
| `FirstYear`, `LastYear` | 2021, 2025 | the period to load |

`fnSdrYear` reads one year of reports and `fnReference` reads one lookup file. In Web
mode both use `Web.Contents` with a fixed base URL and `RelativePath`, the pattern the
Power BI Service needs to refresh a dataset with a dynamic URL, and the FAA file is
wrapped in `Binary.Buffer` so it is downloaded once.

## Pages

| Page | Visuals |
|---|---|
| Overview | KPI cards, reports vs. unscheduled landings by year with drill-down to months (combo), Key findings (text measures), reports by aircraft system (drill-down; the title names the group or chapter you drilled into), explorer chart driven by the `Analyze By` field parameter, flight phase donut |
| Systems | Pareto (top 15 chapters, conditional colors), 100% stacked finding mix by system group, chapter x year heat map (matrix, expandable to systems), latest vs. previous year using the `Year Comparison` calculation group |
| Aging fleet | 100% stacked finding mix by airframe hours, scatter of aircraft families (filtered to families with 1,500+ reports), fleet drill-down, parts most often corroded or cracked |
| In-flight events | KPIs for unscheduled landings, aborted takeoffs, engine shutdowns, smoke or fumes; year > quarter > month drill-down; system x flight phase heat map; crew actions, symptoms, systems behind unscheduled landings |
| Engines & APU | page filter on the Powerplant & APU system group; systems, engine manufacturers, discovery methods, most reported engine parts |
| Report details | drill-through target (chapter, system, family, finding, part, flight phase) with the individual reports and descriptions |
| Tooltip | report-page tooltip used by the system, finding-mix and fleet charts |

## Design

- Page backgrounds (header bar, navigation tabs, tiles, KPI icons) are images in
  `AviationReliability.Report/StaticResources/RegisteredResources/`; visuals sit on top
  with transparent backgrounds.
- The tabs in the header are page navigation buttons (Ctrl + click in Desktop).
- The four filters are synced across pages; **Reset filters** clears them.
- `theme.json` sets the palette, fonts and axis styles.
