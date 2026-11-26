// Table: System

let
    Source = fnReference("jasc_codes"),
    Typed = Table.TransformColumnTypes(Source, {{"system_group_order", Int64.Type}}),
    Renamed = Table.RenameColumns(Typed, {
        {"jasc_code", "JASC Code"}, {"system", "System Name"}, {"chapter_code", "Chapter Code"}, {"chapter", "Chapter"},
        {"system_group", "System Group"}, {"system_group_order", "System Group Order"}
    }),
    WithSystem = Table.AddColumn(Renamed, "System", each [JASC Code] & " " & [System Name], type text),
    WithChapterName = Table.AddColumn(WithSystem, "Chapter Name", each Text.AfterDelimiter([Chapter], " "), type text)
in
    WithChapterName
