// Table: Aircraft

let
    Models = fnReference("aircraft_models"),
    Makes = fnReference("aircraft_makes"),
    Rules = Table.Buffer(fnReference("aircraft_families")),
    // Longest matching model prefix wins; a rule with a suffix (A320neo "N"/"NX") beats one without
    MatchFamily = (make as text, model as text) as nullable record =>
        let
            Candidates = Table.SelectRows(Rules, each [make_code] = make and Text.StartsWith(model, [model_prefix])
                and ([model_suffix] = "" or Text.EndsWith(model, [model_suffix]))),
            Scored = Table.AddColumn(Candidates, "score", each Text.Length([model_prefix]) + (if [model_suffix] = "" then 0 else 100))
        in
            if Table.IsEmpty(Scored) then null else Table.Max(Scored, "score"),
    WithMake = Table.NestedJoin(Models, {"make_code"}, Makes, {"make_code"}, "Make", JoinKind.LeftOuter),
    Expanded = Table.ExpandTableColumn(WithMake, "Make", {"manufacturer", "default_category"}),
    WithMatch = Table.AddColumn(Expanded, "Match", each MatchFamily([make_code], [model_code])),
    WithKey = Table.AddColumn(WithMatch, "Aircraft Key", each [make_code] & "|" & [model_code], type text),
    WithManufacturer = Table.AddColumn(WithKey, "Manufacturer", each
        if [make_code] = "" then "Not reported" else if [manufacturer] = null then [make_code] else [manufacturer], type text),
    WithFamily = Table.AddColumn(WithManufacturer, "Family", each
        if [Match] <> null then [Match][family] else if [make_code] = "" then "Not reported" else [Manufacturer] & " (other)", type text),
    WithCategory = Table.AddColumn(WithFamily, "Category", each
        if [Match] <> null then [Match][category] else if [make_code] = "" then "Not reported"
        else if [default_category] = null then "Other" else [default_category], type text),
    WithModel = Table.AddColumn(WithCategory, "Model", each if [model_code] = "" then "(model not reported)" else [model_code], type text),
    CategoryOrder = Table.AddColumn(WithModel, "Category Order", each
        List.PositionOf({"Narrowbody", "Widebody", "Regional jet", "Turboprop", "Business jet", "Helicopter", "Piston / light", "Other", "Not reported"}, [Category]) + 1, Int64.Type),
    Result = Table.SelectColumns(CategoryOrder, {"Aircraft Key", "Manufacturer", "Family", "Model", "Category", "Category Order"})
in
    Result
