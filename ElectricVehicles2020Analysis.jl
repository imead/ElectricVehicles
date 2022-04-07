## Download required packages
using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")

## Load required packages
using CSV
using DataFrames

## Read in first CSV
a1 = CSV.File("Colorado_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv")

Colorado = CSV.read("Colorado_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; header=6, DataFrame)

## pass to DataFrame
## 04/06/22 running into issues with the header and also with IOBuffer (from CSV.jl documentation)
californiadf = CSV.File("California_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv"; header=2)

a = CSV.read("test.csv", DataFrame)

## Find active directory to check path 
pwd()

## This give valid sink argument error, this code is used in all the examples so it should work
## Also checked with full path and it still gave an error. Seems like it is an issue with VS Code.
CSV.read("C:\\Users\\ivylm\\Git\\ElectricVehicles\\test.csv", DataFrame)

CSV.read("C:\\Users\\ivylm\\Git\\ElectricVehicles\\California_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv", DataFrame)

## Trying to get CSV.jl function skipto to work to remove text header
Colorado = CSV.read("C:\\Users\\ivylm\\Git\\ElectricVehicles\\Colorado_All_Grades_All_Formulations_Retail_Gasoline_Prices.csv", DataFrame, header=6)