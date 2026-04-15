-- =====================================================
-- EXPLORATORY DATA ANALYSIS (EDA) ON LAYOFFS DATA
-- Objective: Understand patterns, trends, and key insights
-- =====================================================

-- View the full dataset to get an overview of the data
SELECT * 
FROM layoffs_staging2;


-- Check the maximum values for layoffs and layoff percentages
-- This helps identify extreme cases in the dataset
SELECT 
    MAX(total_laid_off) AS max_layoffs,
    MAX(percentage_laid_off) AS max_percentage
FROM layoffs_staging2; 


-- Identify records where 100% of employees were laid off
-- These are critical cases (company shutdown or full workforce reduction)
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Calculate total layoffs per company
-- Helps identify which companies had the highest layoffs overall
SELECT  
    company, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC;


-- Determine the time range of the dataset
-- Shows the earliest and latest layoff dates
SELECT 
    MIN(`date`) AS start_date,
    MAX(`date`) AS end_date
FROM layoffs_staging2;


-- Analyze layoffs by industry
-- Useful for identifying which industries were most affected
SELECT  
    industry, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;


-- Analyze layoffs by country
-- Helps compare impact across different regions
SELECT  
    country, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;


-- Analyze layoffs by year
-- Useful for identifying yearly trends
SELECT  
    YEAR(`date`) AS year, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY year DESC;


-- Analyze layoffs by company stage (e.g., startup, public, etc.)
-- Helps understand which business stages are most vulnerable
SELECT  
    stage, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;


-- Calculate average layoff percentage per company
-- Helps identify companies with consistently high layoffs relative to size
SELECT  
    company, 
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY avg_percentage_laid_off DESC;


-- Aggregate layoffs by month
-- Converts date into YYYY-MM format for monthly trend analysis
SELECT 
    SUBSTRING(`date`, 1, 7) AS month, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
GROUP BY month
ORDER BY month;


-- Calculate rolling (cumulative) total layoffs over time
-- Helps visualize how layoffs accumulate month by month
WITH Rolling_Total AS (
    SELECT 
        SUBSTRING(`date`, 1, 7) AS month,
        SUM(total_laid_off) AS total_off 
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL 
    GROUP BY month
    ORDER BY month
)
SELECT 
    month,
    total_off, 
    SUM(total_off) OVER(ORDER BY month) AS rolling_total
FROM Rolling_Total;


-- Analyze layoffs per company per year
-- Helps identify which companies had the most layoffs each year
SELECT  
    company,
    YEAR(`date`) AS year, 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY total_layoffs DESC;


-- Rank companies by layoffs per year
-- Shows the top 5 companies with the highest layoffs for each year
WITH Company_Year (company, years, total_laid_off) AS (
    SELECT  
        company,
        YEAR(`date`),
        SUM(total_laid_off) 
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
), 

Company_Year_Rank AS (
    SELECT 
        *, 
        DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS `Rank`
    FROM Company_Year
    WHERE years IS NOT NULL
)

-- Filter to top 5 companies per year
SELECT * 
FROM Company_Year_Rank 
WHERE `Rank` <= 5;