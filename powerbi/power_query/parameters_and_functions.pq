// Parameters and functions (from expressions.tmdl). DataFolder is only used in Folder mode.

expression SourceMode = "Folder" meta [IsParameterQuery=true, List={"Folder", "Web"}, DefaultValue="Folder", Type="Text", IsParameterQueryRequired=true]

expression DataFolder = "C:\path\to\aviation-reliability-dashboard\data\" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]

expression ReferenceUrl = "https://raw.githubusercontent.com/SabaTamizi-eng/aviation-reliability-dashboard/main/data/reference/" meta [IsParameterQuery=true, Type="Text", IsParameterQueryRequired=true]

expression FirstYear = 2021 meta [IsParameterQuery=true, Type="Number", IsParameterQueryRequired=true]

expression LastYear = 2025 meta [IsParameterQuery=true, Type="Number", IsParameterQueryRequired=true]

expression fnReference =
    // Reads one of the small lookup files in data/reference (from GitHub, or a local copy of the repo)
    (name as text) as table =>
    let
        Source =
            if SourceMode = "Folder" then
                File.Contents(DataFolder & "reference\" & name & ".csv")
            else
                Web.Contents(ReferenceUrl, [RelativePath = name & ".csv"]),
        Csv = Csv.Document(Source, [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
        Promoted = Table.PromoteHeaders(Csv, [PromoteAllScalars = true])
    in
        Promoted

expression fnSdrYear =
    // One year of Service Difficulty Reports, straight from the FAA download page (or data\raw in Folder mode)
    (year as number) as table =>
    let
        FileName = "SDR-" & Text.From(year) & ".csv",
        Source =
            if SourceMode = "Folder" then
                File.Contents(DataFolder & "raw\" & FileName)
            else
                // buffered so each file is downloaded once, not once per step
                Binary.Buffer(Web.Contents("https://external.apic4e.faa.gov/sdrs/retrieve/", [RelativePath = FileName])),
        Csv = Csv.Document(Source, [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
        Promoted = Table.PromoteHeaders(Csv, [PromoteAllScalars = true]),
        Kept = Table.SelectColumns(Promoted, {"OperatorControlNumber", "DifficultyDate", "SubmissionDate", "SubmitterTypeCode", "SDRType", "JASCCode", "NatureOfConditionA", "NatureOfConditionB", "NatureOfConditionC", "PrecautionaryProcedureA", "PrecautionaryProcedureB", "PrecautionaryProcedureC", "PrecautionaryProcedureD", "StageOfOperationCode", "HowDiscoveredCode", "RegistryNNumber", "AircraftMake", "AircraftModel", "AircraftTotalTime", "EngineMake", "PartName", "PartCondition", "Discrepancy"}, MissingField.UseNull)
    in
        Kept
