// Table: SDR

let
    Years = List.Numbers(FirstYear, LastYear - FirstYear + 1),
    Combined = Table.Combine(List.Transform(Years, fnSdrYear)),
    // Trim every field and turn empty strings into nulls
    Cleaned = Table.TransformColumns(
        Combined,
        List.Transform(Table.ColumnNames(Combined), (c) => {c, each let t = if _ = null then null else Text.Trim(_) in if t = "" then null else t, type nullable text})
    ),
    WithDate = Table.AddColumn(Cleaned, "Difficulty Date", each try Date.FromText([DifficultyDate], [Format = "MM/dd/yyyy", Culture = "en-US"]) otherwise null, type date),
    InRange = Table.SelectRows(WithDate, each [Difficulty Date] <> null and Date.Year([Difficulty Date]) >= FirstYear and Date.Year([Difficulty Date]) <= LastYear),
    WithSubmitted = Table.AddColumn(InRange, "Submission Date", each try Date.From(DateTimeZone.FromText([SubmissionDate])) otherwise null, type date),
    // Days between the event and the report; negative or over a year means a bad date
    WithDays = Table.AddColumn(WithSubmitted, "Days to Submit", each
        let d = if [Submission Date] = null then null else Duration.Days([Submission Date] - [Difficulty Date])
        in if d = null or d < 0 or d > 365 then null else d, Int64.Type),
    WithHours = Table.AddColumn(WithDays, "Airframe Hours", each
        let h = try Number.FromText([AircraftTotalTime], "en-US") otherwise null
        in if h = null or h <= 0 or h > 200000 then null else h, type number),
    WithBandOrder = Table.AddColumn(WithHours, "Hours Band Order", each
        if [Airframe Hours] = null then 99 else List.Min({Number.IntegerDivide([Airframe Hours], 10000), 8}), Int64.Type),
    WithBand = Table.AddColumn(WithBandOrder, "Airframe Hours Band", each
        let o = [Hours Band Order] in
        if o = 99 then "Not reported"
        else if o = 0 then "Under 10k"
        else if o = 8 then "80k+"
        else Text.From(o * 10) & "k-" & Text.From(o * 10 + 10) & "k", type text),
    // A report can list up to four precautionary procedures and three conditions
    WithProcedures = Table.AddColumn(WithBand, "Procedures", each List.RemoveNulls({[PrecautionaryProcedureA], [PrecautionaryProcedureB], [PrecautionaryProcedureC], [PrecautionaryProcedureD]})),
    WithNatures = Table.AddColumn(WithProcedures, "Natures", each List.RemoveNulls({[NatureOfConditionA], [NatureOfConditionB], [NatureOfConditionC]})),
    Flags = List.Accumulate(
        {
            {"Unscheduled Landing", {"A"}},
            {"Emergency Descent", {"B"}},
            {"Aborted Takeoff", {"C"}},
            {"Return to Gate", {"D"}},
            {"Engine Shutdown", {"E"}},
            {"Operational Impact", {"A", "B", "C", "D", "E", "F", "G", "I", "J", "L", "R"}}
        },
        WithNatures,
        (state, flag) => Table.AddColumn(state, flag{0}, each List.ContainsAny([Procedures], flag{1}), type logical)
    ),
    WithSmoke = Table.AddColumn(Flags, "Smoke or Fumes", each List.ContainsAny([Natures], {"A", "B"}), type logical),
    // Part names come in capitals; keep common abbreviations in capitals after Text.Proper
    Acronyms = {"APU", "ECU", "EEC", "FADEC", "IDG", "HPT", "LPT", "HPC", "LPC", "EGT", "PCU", "CVR", "FDR", "ELT", "ADC", "ADIRU", "FMC", "FMS", "GPS", "VHF", "HF", "TCAS", "EICAS", "LED", "O2", "PSU", "AC", "DC", "CSD", "TRU", "GCU", "BPCU", "PTU", "RAT", "HMU", "FCU", "IGV", "VSV", "LRU", "ADF", "DME", "VOR", "ILS", "AOA", "RVDT", "LVDT", "ACM", "PRSOV", "TR"},
    WithAircraftKey = Table.AddColumn(WithSmoke, "Aircraft Key", each
        (if [AircraftMake] = null then "" else [AircraftMake]) & "|" & (if [AircraftModel] = null then "" else [AircraftModel]), type text),
    Defaults = Table.TransformColumns(WithAircraftKey, {
        {"EngineMake", each if _ = null then "NR" else _, type text},
        {"StageOfOperationCode", each if _ = null then "NR" else _, type text},
        {"HowDiscoveredCode", each if _ = null then "9" else _, type text},
        {"NatureOfConditionA", each if _ = null then "0" else _, type text},
        {"PrecautionaryProcedureA", each if _ = null then "0" else _, type text},
        {"PartCondition", each if _ = null then "NOT REPORTED" else Text.Upper(_), type text},
        {"PartName", each if _ = null then "Not reported" else Text.Combine(List.Transform(Text.Split(Text.Proper(_), " "), (w) => if List.Contains(Acronyms, Text.Upper(w)) then Text.Upper(w) else w), " "), type text},
        {"SDRType", each if _ = "G" then "General aviation" else "Air carrier", type text},
        {"Discrepancy", each if _ = null then null else Text.Start(Text.Clean(Text.Replace(Text.Replace(_, "#(cr)", " "), "#(lf)", " ")), 300), type text}
    }),
    Selected = Table.SelectColumns(Defaults, {
        "OperatorControlNumber", "Difficulty Date", "Submission Date", "Days to Submit", "JASCCode", "Aircraft Key", "EngineMake",
        "StageOfOperationCode", "HowDiscoveredCode", "NatureOfConditionA", "PrecautionaryProcedureA", "SubmitterTypeCode",
        "PartCondition", "SDRType", "RegistryNNumber", "PartName", "Airframe Hours", "Airframe Hours Band", "Hours Band Order",
        "Unscheduled Landing", "Aborted Takeoff", "Engine Shutdown", "Return to Gate", "Emergency Descent",
        "Operational Impact", "Smoke or Fumes", "Discrepancy"
    }),
    Renamed = Table.RenameColumns(Selected, {
        {"OperatorControlNumber", "Report ID"}, {"JASCCode", "JASC Code"}, {"EngineMake", "Engine Make Code"},
        {"StageOfOperationCode", "Stage Code"}, {"HowDiscoveredCode", "Method Code"}, {"NatureOfConditionA", "Symptom Code"},
        {"PrecautionaryProcedureA", "Action Code"}, {"SubmitterTypeCode", "Submitter Code"}, {"PartCondition", "Part Condition"},
        {"SDRType", "Operator Type"}, {"RegistryNNumber", "Registration"}, {"PartName", "Part Name"}
    })
in
    Renamed
