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

## Load required Julia packages
using CSV
using DataFrames

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
californiadf = DataFrame.(CSV.File.("California_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))

## Got an error because I was trying to assign State as a literal which is incorrect, no single or double quotes to name.
insertcols!(californiadf, 3, :State => "California")

## Do the same for another CSV
coloradodf = DataFrame.(CSV.File.("Colorado_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))
insertcols!(coloradodf, 3, :State => "Colorado")

## Test appending the two CSV together
GasPricesUS = vcat(californiadf, coloradodf)

## Prep all the remaining state datasets for gas prices
floridadf = DataFrame.(CSV.File.("Florida_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))
massachusettsdf = DataFrame.(CSV.File.("Massachusetts_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))
minnesotadf = DataFrame.(CSV.File.("Minnesota_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))
newyorkdf = DataFrame.(CSV.File.("New_York_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))
ohiodf = DataFrame.(CSV.File.("Ohio_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))
texasdf = DataFrame.(CSV.File.("Texas_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))
washingtondf = DataFrame.(CSV.File.("Washington_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; skipto=6, header=["Year", "Gasoline Prices(Dollars)"]))

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

## Add PADD Designation
df.newcol = ifelse.((df.A .== 2) .& (df.B .== "F"), "bingo", "no bingo"); df