###################################### Electric Vechicles 2020 Analysis ###################################################
### PROGRAM: ElectricVehicles2020Analysis.jl
### PURPOSE: 
### PROGRAMMER: Ivy Mead
### DATE AUTHORED: 04/06/22 (updated: 04/07/22)
### LANGUAGES: Julia
### PACKAGES/DEPENDENCIES: CSV.jl, DataFrames.jl
### DATA SOURCES:
### END REPORTING:
##########################################################################################################################

## Download required Julia packages
using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("DataFramesMeta")
Pkg.add("Pipe")
Pkg.add("XLSX")

## Load required Julia packages
using CSV
using DataFrames
using DataFramesMeta
using Pipe
using XLSX

## Find active directory to check path, note double backslashes for this application (vs UNIX)
pwd()

## 04/06/22 running into issues with the header and also with IOBuffer (from CSV.jl documentation)
californiadf = CSV.File("California_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; header=2)

## Load in all CSVs into a single DataFrame, trying approach using broadcasting because it should allow me to use the
## header function in CSV.js to bypass the description text at the beginning of the file.
## This works to load in three CSVs, recoding headers and skipping beginning section; however, I need to create a
## new column to identify state.
RegistrationData = DataFrame.(CSV.File.(["California_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv", 
    "Colorado_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv", 
    "Florida_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"
    ]; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))


## Load in single CSV for California and then add new column with state
californiadf = DataFrame.(CSV.File.("California_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))

## Got an error because I was trying to assign State as a literal which is incorrect, no single or double quotes to name.
insertcols!(californiadf, 3, :State => "California")

## Do the same for another CSV
coloradodf = DataFrame.(CSV.File.("Colorado_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
insertcols!(coloradodf, 3, :State => "Colorado")

## Test appending the two CSV together
GasPricesUS = vcat(californiadf, coloradodf)

## Prep all the remaining state datasets for gas prices
floridadf = DataFrame.(CSV.File.("Florida_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
massachusettsdf = DataFrame.(CSV.File.("Massachusetts_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
minnesotadf = DataFrame.(CSV.File.("Minnesota_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
newyorkdf = DataFrame.(CSV.File.("New_York_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
ohiodf = DataFrame.(CSV.File.("Ohio_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
texasdf = DataFrame.(CSV.File.("Texas_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))
washingtondf = DataFrame.(CSV.File.("Washington_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "GasPrices"]))

## Not sure how to loop in this instance so continuing to do multiple line
insertcols!(floridadf, 3, :State => "Florida")
insertcols!(massachusettsdf, 3, :State => "Massachusetts")
insertcols!(minnesotadf, 3, :State => "Minnesota")
insertcols!(newyorkdf, 3, :State => "New York")
insertcols!(ohiodf, 3, :State => "Ohio")
insertcols!(texasdf, 3, :State => "Texas")
insertcols!(washingtondf, 3, :State => "Washington")

## Clear variable
GasPricesUS = 0

## Append all prepped 
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

## Import EV registration counts by state for 2020. This file is Excel 10962-ev-registration-counts-by-state_123120.xlsx
## Had to manually edit the Excel file since it seems the advanced functions for XLSX.jl for DataFrames is a little
## complex. readtable at least allows for selection of correct sheet if format is manually cleaned. Will research more.

Registrationdf = DataFrame(XLSX.readtable("10962-ev-registration-counts-by-state_123120.xlsx", "Condensed")...)

## Write out two datasets to CSV for Tableau (I will recode the states for registration into regions in Tableau)
CSV.write("EVRegistration2020.csv", Registrationdf)
CSV.write("GasPrices.csv", GasPricesUS)