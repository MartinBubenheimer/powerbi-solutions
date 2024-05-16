// Format date table created from comatible PowerQuery script
// Code for data table version with fiscal year!
// Author: Martin Bubenheimer
// Language version: Descriptions in English

var sb = new System.Text.StringBuilder();
string newline = Environment.NewLine;

// Remove Power BI default implicit measures:
foreach(var c in Selected.Table.Columns.Where(a => a.DataType == DataType.Int64 || a.DataType == DataType.Decimal || a.DataType == DataType.Double)) {
    c.SummarizeBy = AggregateFunction.None;
}

// For each column in Date table, set sort by column, visibility, format, data category, and folders.
foreach(var c in Selected.Table.Columns) {
    if (c.Name == "Calendar Year Days 2 Go") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Remaining days in current year as of today are marked with 1, all other days are marked with 0.";
    }
    if (c.Name == "Calendar Year Offset #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "#,0";
        c.Description = "Current calendar year is 0, past years are -1, -2, -3, ..., future years are 1, 2, 3, ...";
    }
    if (c.Name == "Date") {
        c.DisplayFolder = "";
        c.FormatString = "m/d/yyyy";
        c.DataCategory = "Date";
        c.IsKey = true; // Indicates date column in date table of the semantic model
        c.Description = "The main date column of the semantic model. Facts are filtered by this date if not stated otherwise in a specific measure.";
    }
    if (c.Name == "Date Natural Key #") {
        c.DisplayFolder = "";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Numeric date key in the format YYYYMMDD";
    }
    if (c.Name == "Date Surrogate Key #") {
        c.DisplayFolder = "";
        c.IsHidden = true;
        c.IsAvailableInMDX = true;
        c.FormatString = "0";
        c.Description = "Incremental numeric date key starting at 1, incrementing by one per each date, sorted by date ascending. " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Day of Month #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "0";
        c.DataCategory = "DayOfMonth";
        c.Description = "The day part of the date as number.";
    }
    if (c.Name == "Day of Week #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "0";
        c.DataCategory = "DayOfWeek";
        c.Description = "Number representing the weekday (seven distinct consecutive sorted values).";
    }
    if (c.Name == "Day of Year #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "0";
        c.DataCategory = "DayOfYear";
        c.Description = "Counting the days of the year, starting at 1 for January 1ˢᵗ and ending at 365 resp. 366 in leap years.";
    }
    if (c.Name == "Day Offset #") {
        c.DisplayFolder = "Filter";
        c.FormatString = "#,0";
        c.Description = "Current day is 0, past days are -1, -2, -3, ..., future days are 1, 2, 3, ... " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "End of Month Date") {
        c.DisplayFolder = "Aggregation";
        c.FormatString = "mmm yyyy";
        c.Description = "For each date, represents the corresponding end of month date in format MMM YYYY. Use to aggregate values by month on a continuous date axis and display as month and year label.";
    }
    if (c.Name == "End of Week Date") {
        c.DisplayFolder = "Aggregation";
        c.FormatString = "m/d/yyyy";
        c.Description = "For each date, represents the corresponding end of week date in format m/d/yyyy. Use to aggregate values by week on a continuous date axis.";
    }
    if (c.Name == "Fiscal Halfyear") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Halfyear of the fiscal year as text label: FHY 1 or FHY 2";
    }
    if (c.Name == "Fiscal Halfyear #") {
        c.DisplayFolder = "Fiscal Year";
        c.FormatString = "0";
        c.DataCategory = "FiscalHalfyearOfYear";
        c.Description = "Halfyear of the fiscal year represented as number: 1 or 2";
    }
    if (c.Name == "Fiscal Halfyear & Fiscal Year") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Halfyear of the fiscal year and fiscal year as text label, e.g.: FHY 1-FY 2020 " + Environment.NewLine + "Sorted by [Fiscal Halfyear Surrogate Key #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Fiscal Halfyear Surrogate Key #").First();
    }
    if (c.Name == "Fiscal Halfyear Days 2 Go") {
        c.DisplayFolder = "Fiscal Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Remaining days in current fiscal halfyear as of today are marked with 1, all other days are marked with 0.";
    }
    if (c.Name == "Fiscal Halfyear Offset #") {
        c.DisplayFolder = "Fiscal Year";
        c.FormatString = "#,0";
        c.DataCategory = "FiscalHalfyears";
        c.Description = "Current fiscal halfyear is 0, past fiscal halfyears are -1, -2, -3, ..., future fiscal halfyears are 1, 2, 3, ... " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Fiscal Halfyear Surrogate Key #") {
        c.DisplayFolder = "Fiscal Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = true;
        c.FormatString = "0";
        c.DataCategory = "FiscalHalfyears";
        c.Description = "Incremental numeric fiscal halfyear key starting at 1, incrementing by one per each fiscal halfyear, sorted by date ascending. " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Fiscal Month #") {
        c.DisplayFolder = "Fiscal Year";
        c.FormatString = "0";
        c.DataCategory = "FiscalMonthOfYear";
        c.Description = "Fiscal month number: 1..12";
    }
    if (c.Name == "Fiscal Month (letter)") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Name of fiscal month as letter, e.g.: A, M, J, ... Different months with same letter are separate months. Fiscal month has different sorting with different starting month than calendar year month. " + Environment.NewLine + "Sorted by [Fiscal Month #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Fiscal Month #").First();
    }
    if (c.Name == "Fiscal Month (long)") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Full name of fiscal month, e.g.: April, May, June, ... Fiscal month has different sorting with different starting month than calendar year month. " + Environment.NewLine + "Sorted by [Fiscal Month #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Fiscal Month #").First();
    }
    if (c.Name == "Fiscal Month (short)") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Abbreviated name of fiscal month, e.g.: Apr, May, Jun, ... Fiscal month has different sorting with different starting month than calendar year month. " + Environment.NewLine + "Sorted by [Fiscal Month #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Fiscal Month #").First();
    }
    if (c.Name == "Fiscal Quarter") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Fiscal quarter of the fiscal year as text label, e.g.: FQ 1, FQ 2, FQ 3, ... ";
    }
    if (c.Name == "Fiscal Quarter #") {
        c.DisplayFolder = "Fiscal Year";
        c.FormatString = "0";
        c.DataCategory = "FiscalQuarterOfYear";
        c.Description = "Fiscal quarter number: 1..4";
    }
    if (c.Name == "Fiscal Quarter & Fiscal Year") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Quarter of the fiscal year and fiscal year as text label, e.g.: FQ 1-FY 2020 " + Environment.NewLine + "Sorted by [Fiscal Quarter Surrogate Key #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Fiscal Quarter Surrogate Key #").First();
    }
    if (c.Name == "Fiscal Quarter Days 2 Go") {
        c.DisplayFolder = "Fiscal Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Remaining days in current fiscal quarter as of today are marked with 1, all other days are marked with 0.";
    }
    if (c.Name == "Fiscal Quarter Offset #") {
        c.DisplayFolder = "Fiscal Year";
        c.FormatString = "#,0";
        c.DataCategory = "FiscalQuarters";
        c.Description = "Current fiscal quarter is 0, past fiscal quarters are -1, -2, -3, ..., future fiscal quarters are 1, 2, 3, ... " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Fiscal Quarter Surrogate Key #") {
        c.DisplayFolder = "Fiscal Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = true;
        c.FormatString = "0";
        c.DataCategory = "FiscalQuarters";
        c.Description = "Incremental numeric fiscal quarter key starting at 1, incrementing by one per each fiscal quarter, sorted by date ascending. " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Fiscal Year") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Fiscal year as text label, e.g.: FY 2020, FY 2021, FY 2022, ... ";
    }
    if (c.Name == "Fiscal Year #") {
        c.DisplayFolder = "Fiscal Year";
        c.FormatString = "0";
        c.DataCategory = "FiscalYears";
        c.Description = "Fiscal year as number, e.g.: 2020, 2021, 2022, ... ";
    }
    if (c.Name == "Fiscal Year & Fiscal Halfyear") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Fiscal year and halfyear of the fiscal year as text label, e.g.: FY 2020-FHY 1";
    }
    if (c.Name == "Fiscal Year & Fiscal Quarter") {
        c.DisplayFolder = "Fiscal Year";
        c.Description = "Fiscal year and quarter of the fiscal year as text label, e.g.: FY 2020-FQ 1";
    }
    if (c.Name == "Fiscal Year Days 2 Go") {
        c.DisplayFolder = "Fiscal Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Remaining days in current fiscal year as of today are marked with 1, all other days are marked with 0.";
    }
    if (c.Name == "Fiscal Year Offset #") {
        c.DisplayFolder = "Fiscal Year";
        c.FormatString = "#,0";
        c.DataCategory = "FiscalYears";
        c.Description = "Current fiscal year is 0, past fiscal years are -1, -2, -3, ..., future fiscal quarters are 1, 2, 3, ... ";
    }
    if (c.Name == "Fiscal Year Surrogate Key #") {
        c.DisplayFolder = "Fiscal Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.DataCategory = "FiscalYears";
        c.Description = "Incremental numeric fiscal year key starting at 1, incrementing by one per each fiscal year, sorted by date ascending. ";
    }
    if (c.Name == "Full Date Description") {
        c.DisplayFolder = "";
        c.Description = "Date as text label with weekday name, e.g.: April 1ˢᵗ, 2020, April 2ⁿᵈ, 2020, April 3ʳᵈ, 2020, ... " + Environment.NewLine + "Sorted by [Date Surrogate Key #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Date Surrogate Key #").First();
    }
    if (c.Name == "Halfyear (CY)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Halfyear of the calendar year (CY) as text label: HY 1 or HY 2";
    }
    if (c.Name == "Halfyear (CY) #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "0";
        c.DataCategory = "FiscalHalfyearOfYear";
        c.Description = "Halfyear of the calendar year (CY) represented as number: 1 or 2";
    }
    if (c.Name == "Halfyear (CY) & Year") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Halfyear of the calendar year (CY) and calendar year as text label, e.g.: HY 1/2020 " + Environment.NewLine + "Sorted by [Halfyear (CY) Surrogate Key #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Halfyear (CY) Surrogate Key #").First();
    }
    if (c.Name == "Halfyear (CY) Days 2 Go") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Remaining days in current calendar halfyear as of today are marked with 1, all other days are marked with 0.";
    }
    if (c.Name == "Halfyear (CY) Offset #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "#,0";
        c.DataCategory = "Halfyears";
        c.Description = "Current calendar halfyear is 0, past calendar halfyears are -1, -2, -3, ..., future calendar halfyears are 1, 2, 3, ... " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Halfyear (CY) Surrogate Key #") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = true;
        c.FormatString = "0";
        c.DataCategory = "Halfyears";
        c.Description = "Incremental numeric calendar halfyear key starting at 1, incrementing by one per each calendar halfyear, sorted by date ascending. " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "ISO Week #") {
        c.DisplayFolder = "ISO 8601 Week";
        c.FormatString = "0";
        c.DataCategory = "ISO8601WeekOfYear";
        c.Description = "ISO 8601 week of ISO 8601 year represented as number: 1..53 " + Environment.NewLine + "ISO weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO years start on Monday of week 1 and end on Sunday of the last week of the same year, i.e., week 52 resp. 53.";
    }
    if (c.Name == "ISO Week & ISO Year") {
        c.DisplayFolder = "ISO 8601 Week";
        c.DataCategory = "ISO8601Weeks";
        c.Description = "ISO 8601 week of the ISO 8601 year and ISO 8601 year as text label, e.g.: CW 01/2020 " + Environment.NewLine + "ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO 8601 years start on Monday of week 1 and end on Sunday of the last week of the same ISO 8601 year, i.e., week 52 resp. 53." + Environment.NewLine + "Sorted by [ISO Week Surrogate Key #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "ISO Week Surrogate Key #").First();
    }
    if (c.Name == "ISO Week Days 2 Go") {
        c.DisplayFolder = "ISO 8601 Week";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Remaining days in current ISO 8601 week as of today are marked with 1, all other days are marked with 0. " + Environment.NewLine + "ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year.";
    }
    if (c.Name == "ISO Week Offset #") {
        c.DisplayFolder = "ISO 8601 Week";
        c.FormatString = "#,0";
        c.DataCategory = "ISO8601Weeks";
        c.Description = "Current ISO 8601 week is 0, past ISO 8601 week are -1, -2, -3, ..., future ISO 8601 week are 1, 2, 3, ... " + Environment.NewLine + "Counting continues across years. ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO 8601 years start on Monday of week 1 and end on Sunday of the last week of the same ISO 8601 year, i.e., week 52 resp. 53.";
    }
    if (c.Name == "ISO Week Surrogate Key #") {
        c.DisplayFolder = "ISO 8601 Week";
        c.IsHidden = true;
        c.IsAvailableInMDX = true;
        c.FormatString = "0";
        c.DataCategory = "ISO8601Weeks";
        c.Description = "Incremental numeric ISO 8601 week key starting at 1, incrementing by one per each ISO 8601 week, sorted by date ascending. " + Environment.NewLine + "Counting continues across years. ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO 8601 years start on Monday of week 1 and end on Sunday of the last week of the same ISO 8601 year, i.e., week 52 resp. 53.";
    }
    if (c.Name == "ISO Year #") {
        c.DisplayFolder = "ISO 8601 Week";
        c.FormatString = "0";
        c.DataCategory = "ISO8601Years";
        c.Description = "ISO 8601 year as number, e.g.: 2020, 2021, 2022, ... " + Environment.NewLine + "ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO 8601 years start on Monday of week 1 and end on Sunday of the last week of the same ISO 8601 year, i.e., week 52 resp. 53.";
    }
    if (c.Name == "ISO Year & ISO Week") {
        c.DisplayFolder = "ISO 8601 Week";
        c.DataCategory = "ISO8601Weeks";
        c.Description = "ISO 8601 year and ISO 8601 week of the ISO 8601 year as text label, e.g.: 2020-CW 01 " + Environment.NewLine + "ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO 8601 years start on Monday of week 1 and end on Sunday of the last week of the same ISO 8601 year, i.e., week 52 resp. 53.";
    }
    if (c.Name == "Leap Year") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "0";
        c.Description = "All days of a leap year are marked with 1, all other days are marked with 0. Refers to calendar year.";
    }
    if (c.Name == "Month #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "0";
        c.DataCategory = "MonthOfYear";
        c.Description = "Calendar month number: 1..12";
    }
    if (c.Name == "Month & Year") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Month of the calendar year and calendar year as text label, e.g.: Jan 2020 " + Environment.NewLine + "Sorted by [Month Surrogate Key #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Month Surrogate Key #").First();
    }
    if (c.Name == "Month Days 2 Go") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Remaining days in current calendar month as of today are marked with 1, all other days are marked with 0.";
    }
    if (c.Name == "Month Name (letter)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Name of calendar month as letter, e.g.: J, F, M, ... Different months with same letter are separate months. " + Environment.NewLine + "Sorted by [Month #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Month #").First();
    }
    if (c.Name == "Month Name (long)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Full name of calendar month, e.g.: January, February, March, ... " + Environment.NewLine + "Sorted by [Month #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Month #").First();
    }
    if (c.Name == "Month Name (short)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Abbreviated name of calendar month, e.g.: Jan, Feb, Mar, ... " + Environment.NewLine + "Sorted by [Month #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Month #").First();
    }
    if (c.Name == "Month Offset #") {
        c.DisplayFolder = "Filter";
        c.FormatString = "#,0";
        c.Description = "Current calendar month is 0, past calendar months are -1, -2, -3, ..., future calendar months are 1, 2, 3, ... " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Month Surrogate Key #") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = true;
        c.FormatString = "0";
        c.DataCategory = "Months";
        c.Description = "Incremental numeric calendar month key starting at 1, incrementing by one per each calendar month, sorted by date ascending. " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Name of Day (letter)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Weekday name as letter, e.g.: M, T, W, ... Different weekdays with same letter are separate weekdays. " + Environment.NewLine + "Sorted by [Day of Week #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Day of Week #").First();
    }
    if (c.Name == "Name of Day (long)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Full name of weekday, e.g.: January, February, March, ... " + Environment.NewLine + "Sorted by [Day of Week #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Day of Week #").First();
    }
    if (c.Name == "Name of Day (short)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Abbreviated name of weekday, e.g.: Mon, Tue, Wed, ... " + Environment.NewLine + "Sorted by [Day of Week #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Day of Week #").First();
    }
    if (c.Name == "Quarter (CY)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Quarter of the calendar year (CY) as text label, e.g.: Q 1, Q 2, Q 3, ... ";
    }
    if (c.Name == "Quarter (CY) #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "0";
        c.DataCategory = "QuarterOfYear";
        c.Description = "Quarter of the calendar year (CY) number: 1..4";
    }
    if (c.Name == "Quarter (CY) & Year") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Quarter of the calendar year (CY) and calendar year as text label, e.g.: Q 1/2020 " + Environment.NewLine + "Sorted by [Quarter (CY) Surrogate Key #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Quarter (CY) Surrogate Key #").First();
    }
    if (c.Name == "Quarter (CY) Days 2 Go") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Remaining days in current quarter of the calendar year (CY) as of today are marked with 1, all other days are marked with 0.";
    }
    if (c.Name == "Quarter (CY) Offset #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "#,0";
        c.DataCategory = "Quarters";
        c.Description = "Current quarter of the calendar year (CY) is 0, past quarters are -1, -2, -3, ..., future quarters are 1, 2, 3, ... " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Quarter (CY) Surrogate Key #") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = true;
        c.FormatString = "0";
        c.DataCategory = "Quarters";
        c.Description = "Incremental numeric quarter of the calendar year (CY) key starting at 1, incrementing by one per each quarter, sorted by date ascending. " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Start of Month Date") {
        c.DisplayFolder = "Aggregation";
        c.FormatString = "mmm yyyy";
        c.Description = "For each date, represents the corresponding start of month date in format MMM YYYY. Use to aggregate values by month on a continuous date axis and display as month and year label.";
    }
    if (c.Name == "Start of Week Date") {
        c.DisplayFolder = "Aggregation";
        c.FormatString = "m/d/yyyy";
        c.Description = "For each date, represents the corresponding start of week date in format m/d/yyyy. Use to aggregate values by week on a continuous date axis.";
    }
    if (c.Name == "Week & Year") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Week of the calendar year and calendar year as text label, e.g.: CW 01/2020 " + Environment.NewLine + "Sorted by [Week Surrogate Key #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Week Surrogate Key #").First();
    }
    if (c.Name == "Week Days 2 Go") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.Description = "Remaining days in current week of the calendar year as of today are marked with 1, all other days are marked with 0. ";
    }
     if (c.Name == "Week of Year #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "0";
        c.DataCategory = "WeekOfYear";
        c.Description = "Week number of the calendar year: 1..12";
    }
    if (c.Name == "Week Offset #") {
        c.DisplayFolder = "Filter";
        c.FormatString = "#,0";
        c.Description = "Current week is 0, past weeks are -1, -2, -3, ..., future weeks are 1, 2, 3, ... " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Week Surrogate Key #") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = true;
        c.FormatString = "0";
        c.DataCategory = "Weeks";
        c.Description = "Incremental numeric week key starting at 1, incrementing by one per each week of the calendar year, sorted by date ascending. " + Environment.NewLine + "Counting continues across years.";
    }
    if (c.Name == "Working Day Flag") {
        c.DisplayFolder = "Filter";
        c.FormatString = "0";
        c.Description = "Tags all weekdays Monday to Friday as working day and Saturday to Sunday as weekend: Working Day or Weekend. " + Environment.NewLine + "Does not take into account public holidays.";
    }
    if (c.Name == "Year #") {
        c.DisplayFolder = "Calendar Year";
        c.FormatString = "0";
        c.DataCategory = "Years";
        c.Description = "Calendar year as number: 2020, 2021, 2022, ... ";
    }
    if (c.Name == "Year & Halfyear (CY)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Calendar year and halfyear of the calendar year as text label, e.g.: FY 2020-HY 1";
    }
    if (c.Name == "Year & Month") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Calendar year and month of the calendar year as text label, e.g.: 2020 Jan" + Environment.NewLine + "Sorted by [Month Surrogate Key #]";
        c.SortByColumn = Selected.Table.Columns.Where(a => a.Name == "Month Surrogate Key #").First();
    }
    if (c.Name == "Year & Quarter (CY)") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Calendar year and quarter of the calendar year as text label, e.g.: FY 2020-Q 1";
    }
    if (c.Name == "Year & Week") {
        c.DisplayFolder = "Calendar Year";
        c.Description = "Calendar year and week of the calendar year as text label, e.g.: 2020-CW 01";
    }
    if (c.Name == "Year Quarter (CY) Surrogate Key #") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.DataCategory = "Quarters";
        c.Description = "Incremental numeric quarter of the calendar year key starting at 1, incrementing by one per each quarter of the calendar year, sorted by date ascending.";
    }
    if (c.Name == "Year Surrogate Key #") {
        c.DisplayFolder = "Calendar Year";
        c.IsHidden = true;
        c.IsAvailableInMDX = false;
        c.FormatString = "0";
        c.DataCategory = "Years";
        c.Description = "Incremental numeric calendar year key starting at 1, incrementing by one per each calendar year, sorted by date ascending.";
    }
    if (c.Name == "FHYTD") {
        c.DisplayFolder = "Filter\\To-Date Comparison";
        c.FormatString = "0";
        c.Description = "Fiscal halfyear-to-date flag: Marks all days from beginning of fiscal halfyear up to today with 1 in current and all other fical halfyears. Otherwise the value is blank. Use for same-for-same comparison of current period with previous periods.";
    }
    if (c.Name == "FYTD") {
        c.DisplayFolder = "Filter\\To-Date Comparison";
        c.FormatString = "0";
        c.Description = "Fiscal year-to-date flag: Marks all days from beginning of fiscal year up to today with 1 in current and all other fiscal years. Otherwise the value is blank. Use for same-for-same comparison of current period with previous periods.";
    }
    if (c.Name == "FQTD") {
        c.DisplayFolder = "Filter\\To-Date Comparison";
        c.FormatString = "0";
        c.Description = "Fiscal quarter-to-date flag: Marks all days from beginning of fiscal quarter up to today with 1 in current and all other fiscal quarters. Otherwise the value is blank. Use for same-for-same comparison of current period with previous periods.";
    }
    if (c.Name == "HYTD") {
        c.DisplayFolder = "Filter\\To-Date Comparison";
        c.FormatString = "0";
        c.Description = "Calendar halfyear-to-date flag: Marks all days from beginning of calendar halfyear up to today with 1 in current and all other calendar halfyears. Otherwise the value is blank. Use for same-for-same comparison of current period with previous periods.";
    }
    if (c.Name == "MTD") {
        c.DisplayFolder = "Filter\\To-Date Comparison";
        c.FormatString = "0";
        c.Description = "Month-to-date flag: Marks all days from beginning of the month up to today with 1 in current and all other months. Otherwise the value is blank. Use for same-for-same comparison of current period with previous periods.";
    }
    if (c.Name == "QTD") {
        c.DisplayFolder = "Filter\\To-Date Comparison";
        c.FormatString = "0";
        c.Description = "Calendar quarter-to-date flag: Marks all days from beginning of calendar quarter up to today with 1 in current and all other calendar quarters. Otherwise the value is blank. Use for same-for-same comparison of current period with previous periods.";
    }
    if (c.Name == "YTD") {
        c.DisplayFolder = "Filter\\To-Date Comparison";
        c.FormatString = "0";
        c.Description = "Calendar year-to-date flag: Marks all days from beginning of fiscal year up to today with 1 in current and all other calendar years. Otherwise the value is blank. Use for same-for-same comparison of current period with previous periods.";
    }
}

// Create hierarchies:
// Label first level with all level names for matrix visual, e.g.: ISO Year, ISO Week, Weekday
// - ISO Week (ISO Year, ISO Week, Date)
// - Calendar Year (Year, Halfyear, Quarter, Month, Day) - year as number, halfyear as label, quarter as label, month 3 characters, day as number (1, 2, 3, ...)
// - Fiscal Year (FY, FHY, FQ, Month, Day) <= Label for level 1, all other levels full name: Fiscal Halfyear, Fiscal Quarter, Fiscal Month, Day

string hierarchyName = "ISO Week Hierarchy";
string levelName = "ISO Year #";
if (!Selected.Table.Hierarchies.Contains(hierarchyName)) {
    Selected.Table.AddHierarchy(hierarchyName);
}
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("ISO Year, ISO Week, Date")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = "ISO Year # " + Environment.NewLine + "ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO 8601 years start on Monday of week 1 and end on Sunday of the last week of the same ISO 8601 year, i.e., week 52 resp. 53.";
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "ISO Year, ISO Week, Date";
}
levelName = "ISO Week #";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("ISO Week")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = "ISO Week # " + Environment.NewLine + "ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO 8601 years start on Monday of week 1 and end on Sunday of the last week of the same ISO 8601 year, i.e., week 52 resp. 53.";
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "ISO Week";
}
levelName = "Date";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("Date")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = "Date " + Environment.NewLine + "ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO 8601 years start on Monday of week 1 and end on Sunday of the last week of the same ISO 8601 year, i.e., week 52 resp. 53.";
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "Date";
}
Selected.Table.Hierarchies[hierarchyName].Description = "ISO Year #, ISO Week #, Date " + Environment.NewLine + "ISO 8601 weeks always start on a Monday. ISO 8601 week 1 is the week of the first Thursday of the calendar year. ISO 8601 years start on Monday of week 1 and end on Sunday of the last week of the same ISO 8601 year, i.e., week 52 resp. 53.";

hierarchyName = "Calendar Year Hierarchy";
levelName = "Year #";
if (!Selected.Table.Hierarchies.Contains(hierarchyName)) {
    Selected.Table.AddHierarchy(hierarchyName);
}
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("Year, Halfyear, Quarter, Month, Day")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = "Fiscal Year #";
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "Year, Halfyear, Quarter, Month, Day";
}
levelName = "Halfyear (CY)";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("Halfyear")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = levelName;
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "Halfyear";
}
levelName = "Quarter (CY)";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("Quarter")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = levelName;
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "Quarter";
}
levelName = "Month Name (long)";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("Month")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = levelName;
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "Month";
}
levelName = "Day of Month #";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("Day")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = levelName;
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "Day";
}

Selected.Table.Hierarchies[hierarchyName].Description = "Year #, Halfyear (CY), Quarter (CY), Month Name (long), Day of Month #";

hierarchyName = "Fiscal Year Hierarchy";
levelName = "Fiscal Year #";
if (!Selected.Table.Hierarchies.Contains(hierarchyName)) {
    Selected.Table.AddHierarchy(hierarchyName);
}
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("FY, FHY, FQ, Month, Day")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = "Fiscal Year #";
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "FY, FHY, FQ, Month, Day";
}
levelName = "Fiscal Halfyear";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains(levelName)) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = levelName;
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = levelName;
}
levelName = "Fiscal Quarter";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains(levelName)) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = levelName;
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = levelName;
}
levelName = "Fiscal Month (long)";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("Fiscal Month")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = levelName;
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "Fiscal Month";
}
levelName = "Day of Month #";
if (!Selected.Table.Hierarchies[hierarchyName].Levels.Contains("Day of Month")) {
    Selected.Table.Hierarchies[hierarchyName].AddLevel(levelName);
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Description = levelName;
    Selected.Table.Hierarchies[hierarchyName].Levels[levelName].Name = "Day of Month";
}

Selected.Table.Hierarchies[hierarchyName].Description = "Fiscal Year #, Fiscal Halfyear, Fiscal Quarter, Fiscal Month (long), Day of Month #";

// Mark as date table:
// 1. Remove date table attributes from all other tables
foreach(var t in Model.Tables) {
    if ( t.DataCategory == "Time" ) {
        t.RemoveAnnotation("PBI_NavigationStepName");
        t.DataCategory = "";
    }
}
// 2. Add date table attributes to selected table
Selected.Table.DataCategory = "Time";
Selected.Table.SetAnnotation("PBI_NavigationStepName", "Navigation");
Selected.Table.Description = "Date dimension";
