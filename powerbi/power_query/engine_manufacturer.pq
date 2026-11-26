// Table: Engine Manufacturer

let
    Source = fnReference("engine_makes"),
    WithNotReported = Table.Combine({Source, #table({"engine_make_code", "engine_manufacturer"}, {{"NR", "Not reported"}})}),
    Renamed = Table.RenameColumns(WithNotReported, {{"engine_make_code", "Engine Make Code"}, {"engine_manufacturer", "Engine Manufacturer"}})
in
    Renamed
