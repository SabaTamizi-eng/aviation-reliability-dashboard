// Table: Flight Phase

let
    Source = fnReference("stage_of_operation"),
    Typed = Table.TransformColumnTypes(Source, {{"phase_group_order", Int64.Type}, {"stage_order", Int64.Type}}),
    Renamed = Table.RenameColumns(Typed, {{"stage_code", "Stage Code"}, {"stage", "Stage"}, {"phase_group", "Phase Group"}, {"phase_group_order", "Phase Group Order"}, {"stage_order", "Stage Order"}})
in
    Renamed
