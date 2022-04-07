## Download required packages
using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")

## Load required packages
using CSV
using DataFrames

## Read in first CSV
California = CSV.File("California_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv")

## pass to DataFrame
## 04/06/22 running into issues with the header and also with IOBuffer (from CSV.jl documentation)
californiadf = CSV.File(IOBuffer("California_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"); header=2)