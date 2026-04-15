# Layoffs Data Cleaning Project

## What this project is about

I cleaned a layoffs dataset using SQL to make it usable for analysis. The raw data had duplicates, messy text values, inconsistent formats, and missing information. I fixed those issues step by step and created a clean version of the dataset.

## What I aimed to do

* Remove duplicate rows
* Fix inconsistent text values
* Handle missing or blank data
* Convert columns into the correct format
* Keep the dataset clean and reliable for analysis

## About the dataset

The dataset includes company layoffs information such as:

* Company name
* Location
* Industry
* Total employees laid off
* Percentage laid off
* Date
* Company stage
* Country
* Funds raised

## How I cleaned the data

### 1. Created a staging table

I first copied the raw dataset into a new table. This step protects the original data in case something goes wrong during cleaning.

### 2. Removed duplicates

I used a window function called `ROW_NUMBER()` to find duplicate rows. After identifying them, I deleted the extra copies and kept only unique records.

### 3. Standardized values

Some columns had inconsistent entries:

* I removed extra spaces in company names
* I grouped similar industry values like “Crypto%” into “Crypto”
* I fixed country names like “United States.” into “United States”

### 4. Fixed the date format

The date column was stored as text. I converted it into a proper SQL date format so it can be used in analysis.

### 5. Handled missing data

* I checked for NULL and blank values
* I replaced blank values with NULL
* I filled missing industry values using other rows from the same company
* I removed rows where key layoff data was missing

### 6. Final cleanup

I removed temporary columns used during cleaning and reviewed the dataset to make sure everything looked correct.

## Tools I used

* MySQL
* Window functions like `ROW_NUMBER()`
* Common Table Expressions (CTE)

## What I learned

* Cleaning data takes time but makes analysis easier
* Small inconsistencies can affect results
* SQL has strong tools for handling messy data
* It helps to always work on a copy of your data first

## How to run this

1. Load the raw dataset into your SQL database
2. Run the SQL script step by step
3. Check the output after each step
4. Use the cleaned table for your analysis

## Final output

The cleaned dataset is stored in:

* `layoffs_staging2`

You can now use this table for analysis, dashboards, or further projects.
