-- =====================================================
-- DATA CLEANING PROCESS: LAYOFFS DATASET
-- =====================================================

-- Initial data inspection
SELECT * FROM layoffs;

-- Key data cleaning objectives:
-- 1. Remove duplicate records
-- 2. Standardize data formats and values
-- 3. Handle null and blank values
-- 4. Remove unnecessary columns

-- =====================================================
-- STEP 1: CREATE STAGING TABLE
-- Purpose: Preserve raw data and perform transformations safely
-- =====================================================

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * FROM layoffs_staging;

-- Copy raw data into staging table
INSERT layoffs_staging
SELECT * FROM layoffs;

-- =====================================================
-- STEP 2: IDENTIFY DUPLICATES
-- Purpose: Detect duplicate rows using ROW_NUMBER()
-- =====================================================

SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage
) AS row_num
FROM layoffs_staging;

-- Use CTE to isolate duplicate records
WITH duplicate_cte AS (
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

-- Example validation for a specific company
SELECT * 
FROM layoffs_staging
WHERE company = 'Casper';

-- =====================================================
-- STEP 3: REMOVE DUPLICATES
-- Purpose: Retain only unique records
-- =====================================================

-- Create new staging table with row number column
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off INT DEFAULT NULL,
  percentage_laid_off TEXT,
  date TEXT,
  stage TEXT,
  country TEXT,
  funds_raised_millions INT DEFAULT NULL,
  row_num INT
);

SELECT * FROM layoffs_staging2;

-- Insert data with row numbering
INSERT INTO layoffs_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

-- Identify duplicates
SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

-- Delete duplicate records
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Validate cleaned dataset
SELECT * 
FROM layoffs_staging2;

-- =====================================================
-- STEP 4: STANDARDIZE DATA
-- Purpose: Ensure consistency in text fields and formats
-- =====================================================

-- Remove leading/trailing spaces in company names
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

-- Normalize 'Crypto' variations
SELECT * 
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Validate industry values
SELECT DISTINCT industry
FROM layoffs_staging2;

-- Review location values
SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- Review country values
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Standardize 'United States' naming inconsistencies
SELECT * 
FROM layoffs_staging2
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

-- Alternative approach: remove trailing punctuation
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- =====================================================
-- STEP 5: DATE FORMAT CONVERSION
-- Purpose: Convert text-based date into proper DATE type
-- =====================================================

SELECT `date`
FROM layoffs_staging2;

-- Convert string to DATE format
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify column data type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- =====================================================
-- STEP 6: HANDLE NULL AND BLANK VALUES
-- Purpose: Clean incomplete or inconsistent records
-- =====================================================

-- Identify rows with missing layoff data
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Identify missing or blank industry values
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

-- Example validation for a specific company
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

-- Cross-reference industry values within same company
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Convert blank industry values to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populate missing industry values using existing data
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Re-check records with missing layoff values
SELECT * 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- Remove records with insufficient layoff information
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

-- =====================================================
-- STEP 7: FINAL CLEANUP
-- Purpose: Remove helper columns used during processing
-- =====================================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final dataset ready for analysis
SELECT * 
FROM layoffs_staging2;