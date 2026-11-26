// Table: Crew Action

let
    Source = fnReference("precautionary_procedure"),
    Typed = Table.TransformColumnTypes(Source, {{"operational_impact", type logical}}),
    Renamed = Table.RenameColumns(Typed, {{"procedure_code", "Action Code"}, {"procedure", "Crew Action"}, {"operational_impact", "Operational Impact"}})
in
    Renamed
