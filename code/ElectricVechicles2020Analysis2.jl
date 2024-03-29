## Aims for this analysis are to:
## 1) Complete a simple analysis with visualization on electric vechicles
##    in the US.
## 2) Learn to leverage Julia for basic data joins, data manipulation, and
##    vizualization capability.
## Using Julia v1.7 and Quarto 0.9.2  

## Packages required for analysis
using DataFrames
using CSV
using Pipe
using DataFramesMeta
using XLSX
using PlotlyJS
using Statistics

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
Registrationdf = DataFrame(XLSX.readtable("data/10962-ev-registration-counts-by-state_123120.xlsx", "Condensed"))

# Add year data collected
insertcols!(Registrationdf, 3, :Year => 2020)

## Left join Registration data to gas price data
FuelRegCombined = leftjoin(GasPricesUS, Registrationdf, on = [:State, :Year])

## Rename Registration count column to remove spaces, XLSX.jl lacks normalize option
rename!(FuelRegCombined,:"Registration Count" => :RegistrationCount)

## Bar chart looking at EV registrations by state
## Using PlotlyJS instead of CairoMakie, because of how dataframes are handled
registration_bar = plot(
    [bar(FuelRegCombined, x=:State, y=:RegistrationCount, marker_color="gray", text=:RegistrationCount,
    textposition="outside", hovertext=" ")],
    Layout(title="EV Registrations per State in 2020", yaxis_title_text="Registrations",
    xaxis_title_text="State", font_family="Arial", xaxis_categoryorder="total descending")
    )

## Trend graph examining gas prices by state over time.
plot(sort(FuelRegCombined, :Year), kind="scatter", mode="lines+markers", x=:Year, y=:GasPrices,
    group=:State,
    Layout(title="Fuel Prices Over Time"))

## Remove State column, then group by PADD Region and Year, averaging the state prices
## by Region and Year.
summaryregPADD = select(FuelRegCombined, Not(:State))
summaryregPADD = groupby(summaryregPADD, [:PADDReg, :Year])
summaryregPADD = combine(summaryregPADD, [:GasPrices,:RegistrationCount] .=> mean; renamecols=false)

## add new column to allow for plot to highlight the two highest fuel prices
summaryregPADDend = @pipe summaryregPADD |>
             select(_, :PADDReg, :GasPrices, :Year) |>
             @eachrow _ begin
                 @newcol RegionType::Vector{String}
                 :RegionType = :PADDReg == "West Coast" ? "Higher Regions" :
                         :PADDReg == "Central Atlantic" ? "Higher Regions" :
                         "Lower Regions"
             end

## Aggregated fuel prices by region, line graph.
plot(sort(summaryregPADD, :Year), kind="scatter", mode="lines+markers", x=:Year, y=:GasPrices,
    group=:PADDReg,
    Layout(title="Fuel Prices Over Time by Region"))

## Adding different styling for the two regions to highlight
regionhighlight = select(summaryregPADDend, Not(:PADDReg))
regionhighlight = groupby(regionhighlight, [:RegionType, :Year])
regionhighlight = combine(regionhighlight, [:GasPrices] .=> mean; renamecols=false)

plot(sort(regionhighlight, :Year), kind="scatter", mode="lines+markers", x=:Year, y=:GasPrices,
    group=:RegionType,
    Layout(title="Fuel Prices Over Time by Higher Regions vs Lower Regions Averaged"))

## Filter only for 2020 when registration and gas prices overlap
registrationsubset = filter(:Year => ==(2020), FuelRegCombined)
registrationsubset

## scatterplot with registration number of EVs by Gas Prices.
plot(registrationsubset, mode="markers+text", x=:GasPrices, y=:RegistrationCount, color=:State,
    text=:State, textposition="top left",
    Layout(title="States State State", yaxis_title_text="Number of EVs Registered",
    xaxis_title_text="Gas Price (Dollars)", font_family="Arial", xaxis_tickprefix = '$'))
    
