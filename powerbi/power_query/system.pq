// Table: System

let
    Source = fnReference("jasc_codes"),
    Typed = Table.TransformColumnTypes(Source, {{"system_group_order", Int64.Type}}),
    Renamed = Table.RenameColumns(Typed, {
        {"jasc_code", "JASC Code"}, {"system", "System Name"}, {"chapter_code", "Chapter Code"}, {"chapter", "Chapter Title"},
        {"system_group", "System Group"}, {"system_group_order", "System Group Order"}
    }),
    // Names are shown without the JASC number ("53 Fuselage" -> "Fuselage"); the codes are kept to sort by
    WithChapter = Table.AddColumn(Renamed, "Chapter", each Text.AfterDelimiter([Chapter Title], " "), type text),
    WithSystem = Table.AddColumn(WithChapter, "System", each [System Name], type text),
    WithChapterName = Table.AddColumn(WithSystem, "Chapter Name", each [Chapter], type text),
    Result = Table.RemoveColumns(WithChapterName, {"Chapter Title"})
in
    Result
