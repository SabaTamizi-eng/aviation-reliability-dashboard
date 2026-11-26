// Table: Submitter

let
    Source = fnReference("submitter_type"),
    Renamed = Table.RenameColumns(Source, {{"submitter_code", "Submitter Code"}, {"submitter", "Submitter"}, {"submitter_group", "Submitter Group"}})
in
    Renamed
