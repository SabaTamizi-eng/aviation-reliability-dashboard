// Table: Date

let
    StartDate = #date(FirstYear, 1, 1),
    EndDate = #date(LastYear, 12, 31),
    Dates = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    Base = Table.FromList(Dates, Splitter.SplitByNothing(), type table [Date = date]),
    WithYear = Table.AddColumn(Base, "Year", each Date.Year([Date]), Int64.Type),
    WithQuarter = Table.AddColumn(WithYear, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    WithMonthNumber = Table.AddColumn(WithQuarter, "Month Number", each Date.Month([Date]), Int64.Type),
    WithMonth = Table.AddColumn(WithMonthNumber, "Month", each Date.ToText([Date], [Format = "MMM", Culture = "en-US"]), type text),
    WithMonthStart = Table.AddColumn(WithMonth, "Month Start", each Date.StartOfMonth([Date]), type date),
    WithYearMonth = Table.AddColumn(WithMonthStart, "Year Month", each Date.ToText([Date], [Format = "MMM yyyy", Culture = "en-US"]), type text),
    WithYearMonthKey = Table.AddColumn(WithYearMonth, "Year Month Key", each Date.Year([Date]) * 100 + Date.Month([Date]), Int64.Type)
in
    WithYearMonthKey
