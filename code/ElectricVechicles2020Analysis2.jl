
## Packages required for analysis
using DataFrames
using CSV
using Pipe
using DataFramesMeta
using XLSX

## Load in the CSVs containing data for each of the states
californiadf = DataFrame.(CSV.File.("data/California_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
floridadf = DataFrame.(CSV.File.("data/Florida_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
massachusettsdf = DataFrame.(CSV.File.("data/Massachusetts_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
minnesotadf = DataFrame.(CSV.File.("data/Minnesota_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
newyorkdf = DataFrame.(CSV.File.("data/New_York_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
ohiodf = DataFrame.(CSV.File.("data/Ohio_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
texasdf = DataFrame.(CSV.File.("data/Texas_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
washingtondf = DataFrame.(CSV.File.("data/Washington_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
coloradodf = DataFrame.(CSV.File.("data/Colorado_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))

## Create new column State to capture the data name for each when combined
insertcols!(californiadf, 3, :State => "California")
insertcols!(floridadf, 3, :State => "Florida")
insertcols!(massachusettsdf, 3, :State => "Massachusetts")
insertcols!(minnesotadf, 3, :State => "Minnesota")
insertcols!(newyorkdf, 3, :State => "New York")
insertcols!(ohiodf, 3, :State => "Ohio")
insertcols!(texasdf, 3, :State => "Texas")
insertcols!(washingtondf, 3, :State => "Washington")
insertcols!(coloradodf, 3, :State => "Colorado")

## Append all state dataframes together into GasPricesUS
GasPricesUS = vcat(californiadf, coloradodf, floridadf, massachusettsdf, minnesotadf,
    newyorkdf, ohiodf, texasdf, washingtondf)

## Add PADD Designation using conditional logic using DataFramesMeta and Pipe
GasPricesUS = @pipe GasPricesUS |>
             select(_, :Year, :GasPrices, :State) |>
             @eachrow _ begin
                 @newcol PADDReg::Vector{String}
                 :PADDReg = :State == "California" ? "West Coast" :
                         :State == "Colorado" ? "Rocky Mountain" :
                         :State == "Florida" ? "Lower Atlantic" :
                         :State == "Massachusetts" ? "New England" :
                         :State == "Minnesota" ? "Midwest" :
                         :State == "New York" ? "Central Atlantic" :
                         :State == "Ohio" ? "Midwest" :
                         :State == "Texas" ? "Gulf Coast" :
                         :State == "Washington" ? "West Coast" :
                         "Other"
             end

## Import number of EV registrations per state
Registrationdf = DataFrame(XLSX.readtable("data/10962-ev-registration-counts-by-state_123120.xlsx", "Condensed")...)


## Left join Registration data to gas price data
FuelRegCombined = leftjoin(Registrationdf, GasPricesUS, on = :State)