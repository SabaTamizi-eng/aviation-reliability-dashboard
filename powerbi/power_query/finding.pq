// Table: Finding

let
    Source = fnReference("part_conditions"),
    Typed = Table.TransformColumnTypes(Source, {{"condition_group_order", Int64.Type}}),
    Renamed = Table.RenameColumns(Typed, {{"part_condition", "Part Condition Code"}, {"condition_category", "Finding Category"}, {"condition_group", "Finding Group"}, {"condition_group_order", "Finding Group Order"}}),
    Result = Table.AddColumn(Renamed, "Part Condition", each Text.Proper([Part Condition Code]), type text)
in
    Result
