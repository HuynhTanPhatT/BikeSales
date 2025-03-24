
select	dteday,
		season,
		bs.yr,
		weekday,
		hr,
		rider_type,
		riders,
		price,cogs,
		ct.price * bs.riders as revenue,
		ct.price * bs.riders - ct.COGS as Profit
FROM 
(
	SELECT *
    FROM dbo.bike_share_yr_0
    UNION ALL
    SELECT *
    FROM dbo.bike_share_yr_1
) AS bs
LEFT JOIN dbo.Cost_table ct
	ON bs.yr = ct.yr
----------------------------------------------------------------------------------------------------------------------------------------------------------------
										--HourlyRevenueAnalysis
WITH HourlyRevenue AS (
SELECT	DATENAME(WEEKDAY, bs.dteday) AS DayName,
        (CASE 
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Monday' THEN 1
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Tuesday' THEN 2
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Wednesday' THEN 3
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Thursday' THEN 4
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Friday' THEN 5
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Saturday' THEN 6
            ELSE 7 END) AS Day_Numbers,
        bs.hr,
        SUM(ct.price * bs.riders) AS revenue
FROM 
(
	SELECT *
    FROM dbo.bike_share_yr_0
    UNION ALL
    SELECT *
    FROM dbo.bike_share_yr_1
) AS bs
LEFT JOIN dbo.Cost_table ct
	ON bs.yr = ct.yr
GROUP BY bs.hr, bs.dteday,
		(CASE 
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Monday' THEN 1
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Tuesday' THEN 2
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Wednesday' THEN 3
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Thursday' THEN 4
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Friday' THEN 5
            WHEN DATENAME(WEEKDAY, bs.dteday) = 'Saturday' THEN 6
            ELSE 7 END)
--order by hr
)--WEEKDAY&KENDS REVENUES
SELECT	
    (CASE 
        WHEN DayName IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') THEN 'Weekdays'
        ELSE 'Weekends' END) AS "Weekday&kends",
    hr,
    SUM(revenue) AS TotalRevenue
FROM HourlyRevenue
GROUP BY hr, (CASE 
                WHEN DayName IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday') THEN 'Weekdays'
                ELSE 'Weekends' END)
ORDER BY "Weekday&kends", hr ASC;


----------------------------------------------------------------------------------------------------------------------------------------------------------------
										--Profit and revenue trends
select	
		(case
			when bs.yr = '0' then '2021'
			ELSE '2022' END) as Year,
		sum(ct.price * bs.riders)as revenue,
		sum(ct.cogs) as CostOfGoodsSold,
		sum(bs.riders * ct.price) - sum(ct.cogs * bs.riders) as GrossProfit
from 
(
select *
from dbo.bike_share_yr_0
UNION ALL
select *
from dbo.bike_share_yr_1
) as bs
LEFT JOIN dbo.Cost_table ct
	ON bs.yr = ct.yr
group by bs.yr
order by bs.yr asc;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
										--Seasonal revenue
select	
		(case
			when bs.season = 1 then 'Winter'
			when bs.season = 2 then 'Spring'
			when bs.season = 3 then 'Summer'
			ELSE 'Autumn' END ) as Season,
		sum(ct.price * bs.riders) as revenue,
		((sum(bs.riders * ct.price)) - sum(cogs *bs.riders) ) as GrossProfit,
		(sum(bs.riders * ct.price) - sum(ct.COGS * bs.riders)) / sum(bs.riders *ct.price) as GrossMargin,
		sum(cogs* bs.riders) / sum(bs.riders * ct.price) as "COGS Margin"
from 
(
select *
from dbo.bike_share_yr_0
UNION ALL
select *
from dbo.bike_share_yr_1
) as bs
LEFT JOIN dbo.Cost_table ct
	ON bs.yr = ct.yr
group by bs.season
order by season asc;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
										--Rider demographic
select	cast(bs.dteday as date) as date,
		DATENAME(month,bs.dteday) as Month_Name,
		bs.mnth as Month_Number,
		(case 
			when bs.yr = 0 then '2021'
			ELSE '2021' END) as year,
		bs.rider_type,
		sum(bs.riders) as TotalRiders,
		AVG(ct.price * bs.riders)as Averagerevenue,
		AVG(bs.riders * ct.price) - avg(cogs * bs.riders) as AverageGrossProfit
from 
(
select *
from dbo.bike_share_yr_0
UNION ALL
select *
from dbo.bike_share_yr_1
) as bs
LEFT JOIN dbo.Cost_table ct
	ON bs.yr = ct.yr
group by bs.dteday,DATENAME(month,bs.dteday),bs.yr,bs.rider_type,bs.mnth
order by bs.yr asc;
----------------------------------------------------------------------------------------------------------------------------------------------------------------
