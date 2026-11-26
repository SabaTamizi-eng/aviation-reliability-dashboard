// Table: Symptom

let
    Source = fnReference("nature_of_condition"),
    Renamed = Table.RenameColumns(Source, {{"nature_code", "Symptom Code"}, {"nature", "Symptom"}, {"nature_group", "Symptom Group"}})
in
    Renamed
