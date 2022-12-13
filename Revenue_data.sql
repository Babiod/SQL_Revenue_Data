SELECT * FROM dbo.calendar_lookup;
SELECT * FROM dbo.marketing_raw_data;
SELECT * FROM dbo.opportunites_Data;
SELECT * FROM dbo.revenue_raw_data;
SELECT * FROM dbo.targets_raw_data;



--WHAT IS THE TOTAL REVENUE OF THE COMPANY THIS YEAR 2021?

SELECT SUM(Revenue) AS Total_Revenue_FY21 FROM dbo.revenue_raw_data
WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.calendar_lookup WHERE Fiscal_Year = 'fy21');


 
--WHAT IS THE TOTAL REVENUE PERFORMANCE YEAR OVER YEAR(YOY)?

SELECT Total_Revenue_FY21, Total_Revenue_FY20, Total_Revenue_FY21-Total_Revenue_FY20 AS Diff_YoY, Total_Revenue_FY21/Total_Revenue_FY20 AS Perc_Diff_YoY
FROM
(
SELECT 
SUM(Revenue) AS Total_Revenue_FY21 FROM dbo.revenue_raw_data
WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.calendar_lookup WHERE Fiscal_Year = 'fy21')
) a,
(
SELECT SUM(Revenue) AS Total_Revenue_FY20 FROM dbo.revenue_raw_data
WHERE Month_ID IN (SELECT DISTINCT Month_ID-12 FROM dbo.revenue_raw_data
WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.calendar_lookup WHERE Fiscal_Year = 'fy21'))
) b



--What is the Month over Month Revenue Performance ?

SELECT Total_Revenue_TM, Total_Revenue_LM, Total_Revenue_TM-Total_Revenue_LM AS MoM_Dollar_Diff, Total_Revenue_TM/Total_Revenue_LM AS MoM_Perc_Diff
FROM
(
SELECT 
SUM(Revenue) AS Total_Revenue_TM FROM dbo.revenue_raw_data
WHERE Month_ID IN (SELECT MAX(Month_ID)FROM dbo.revenue_raw_data)
) a,
(
SELECT 
SUM(Revenue) AS Total_Revenue_LM FROM dbo.revenue_raw_data
WHERE Month_ID IN (SELECT MAX(Month_ID)-1 FROM dbo.revenue_raw_data)
)b



---What is the Total Revenue vs Target Performance for the year ?

SELECT Total_Revenue_FY21, Target_FY21, Total_Revenue_FY21-Target_FY21 AS Dollar_Diff, Total_Revenue_FY21/Target_FY21 AS Perc_Diff
FROM
(
SELECT
SUM(Revenue) AS Total_Revenue_FY21 FROM dbo.revenue_raw_data
WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.calendar_lookup WHERE Fiscal_year ='fy21')
) a,
(
SELECT SUM(Target) AS Target_FY21 FROM dbo.targets_raw_data
WHERE Month_ID IN ((SELECT DISTINCT Month_ID FROM dbo.revenue_raw_data WHERE Month_ID IN
(SELECT DISTINCT Month_ID FROM dbo.calendar_lookup WHERE Fiscal_year='fy21')))
) b


 --What is the Revenue vs Target Performance Per Month ?
 
 SELECT a.Month_ID, Fiscal_Month, Total_Revenue_FY21, Target_FY21, Total_Revenue_FY21-Target_FY21 AS Dollar_Diff, Total_Revenue_FY21/Target_FY21 AS Perc_Diff
 FROM
 
   (
   SELECT Month_ID,
   SUM(Revenue) AS Total_Revenue_FY21 FROM dbo.revenue_raw_data
   WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.calendar_lookup WHERE Fiscal_year ='fy21')
   GROUP BY Month_ID
   ) a
   LEFT JOIN
   (
   SELECT Month_ID,SUM(Target) AS Target_FY21 FROM dbo.targets_raw_data
   WHERE Month_ID IN ((SELECT DISTINCT Month_ID FROM dbo.revenue_raw_data WHERE Month_ID IN
   (SELECT DISTINCT Month_ID FROM dbo.calendar_lookup WHERE Fiscal_Year= 'fy21')))
   GROUP BY Month_ID
   ) b
   ON a.Month_ID = b.Month_ID
   
   LEFT JOIN
   (
   SELECT DISTINCT Month_ID, Fiscal_Month FROM dbo.calendar_lookup
   ) c
   ON a.Month_ID = c.Month_ID
   
ORDER BY a.Month_ID



--What is the best Performing product in terms of Revenue this year ?

SELECT Product_category,SUM(Revenue) AS Revenue FROM dbo.revenue_raw_data
WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.calendar_lookup WHERE Fiscal_Year= 'fy21')
GROUP BY Product_category
ORDER BY Revenue DESC



--What is the Product Performance vs Target for the Month?

SELECT a.Product_Category, a.Month_ID,Revenue,Target,Revenue/TARGET AS Rev_VS_Target
FROM
  (
  SELECT Product_Category,Month_ID,SUM(Revenue) AS Revenue FROM dbo.revenue_raw_data
  GROUP BY Product_Category,Month_ID
  )a
  LEFT JOIN
  (
  SELECT Product_Category,Month_ID, SUM(Target) AS Target FROM dbo.targets_raw_data
  WHERE Month_ID IN (SELECT MAX(Month_ID) FROM dbo.revenue_raw_data)
  GROUP BY Product_Category,Month_ID
  ) b
  ON a.Month_ID = b.Month_ID and a.Product_Category=b.Product_Category
  
  
  
  --Which account is Performing best in terms of revenue ? 
  
  SELECT a.Account_No, New_Account_Name, Revenue
  FROM
    (
    SELECT Account_No,SUM(Revenue) AS Revenue FROM dbo.revenue_raw_data
    WHERE Month_ID IN (SELECT DISTINCT Month_ID FROM dbo.calendar_lookup WHERE Fiscal_Year ='fy21')
    GROUP BY Account_No
    ) a
	LEFT JOIN
    (SELECT * FROM dbo.account_lookup) b
    ON a.Account_No = b.New_Account_No
 ORDER BY Revenue DESC
 