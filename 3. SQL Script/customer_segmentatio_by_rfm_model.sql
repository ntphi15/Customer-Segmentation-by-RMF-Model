select CustomerID, R, F, M, concat(R, F, M) as RFM,
	(case when R = 1 and F = 1 and M = 1 then "Top customer"
	when (F = 1 and M = 1) or (F = 1 and M = 2) then "Loyal customer"
	when M = 1 then "High potential"
	when (F = 1 and M = 3) or (F = 1 and M = 4) then "Small buyer"
	when R = 4 and F = 4 and M = 4 then "Worst customer"
	when R = 4 and F = 4 then "Dormant customer" else "Other" end) as Category
from (select CustomerID, ntile(4) over (partition by Recency) as R,
	ntile(4) over (order by Frequency desc) as F,
	ntile(4) over (order by Monetary desc) as M, Recency, Frequency, Monetary
	from (select distinct(ct.CustomerID), datediff('2022-09-01', max(ct.Purchase_Date)) as Recency,
		count(distinct(ct.Purchase_Date)) / (datediff('2022-09-01', cr.created_date)/365) as Frequency,
		sum(ct.GMV)	as Monetary
		from customer_transaction ct
		left join customer_registered cr on ct.CustomerID = cr.ID 
		where cr.stopdate is null
		group by CustomerID) A) B