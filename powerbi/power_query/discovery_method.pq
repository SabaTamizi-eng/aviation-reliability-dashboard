// Table: Discovery Method

let
    Source = fnReference("how_discovered"),
    Renamed = Table.RenameColumns(Source, {{"method_code", "Method Code"}, {"method", "Method"}, {"method_group", "Method Group"}})
in
    Renamed
