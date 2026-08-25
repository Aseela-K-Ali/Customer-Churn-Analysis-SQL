use ecomm;
show tables;
select * from customer_churn;

-- DATA CLEANING - Handling Missing Values and Outliers

select WarehouseToHome,HourSpendOnApp,OrderAmountHikeFromlastYear,DaySinceLastOrder,
coalesce (WarehouseToHome,round((select avg(WarehouseToHome)from customer_churn))) as WarehouseToHome_with_Avg,
coalesce (HourSpendOnApp,round((select avg(HourSpendOnApp)from customer_churn))) as HourSpendOnApp_with_Avg,
coalesce (OrderAmountHikeFromlastYear,round((select avg(OrderAmountHikeFromlastYear)from customer_churn))) as OrderAmountHikeFromlastYear_with_Avg,
coalesce (DaySinceLastOrder,round((select avg(DaySinceLastOrder) from customer_churn))) as DaySinceLastOrder_with_Avg 
from customer_churn group by WarehouseToHome,HourSpendOnApp,OrderAmountHikeFromlastYear,DaySinceLastOrder;

select Tenure,CouponUsed,OrderCount,
coalesce(Tenure,(select Tenure from customer_churn group by Tenure order by count(Tenure) desc limit 1)) as frequency_tenure, 
coalesce(CouponUsed,(select CouponUsed from customer_churn group by CouponUsed order by count(CouponUsed) desc limit 1))as frequency_couponUsed,
coalesce(OrderCount,(select OrderCount from customer_churn group by OrderCount order by count(OrderCount) desc limit 1 ))as frequency_ordercount
from customer_churn ;

delete from customer_churn where WarehouseToHome>100;

 ## Dealing With Inconsistencies
 
  update customer_churn set PreferredLoginDevice=replace(PreferredLoginDevice,'Phone','Mobile Phone'),  
                         PreferedOrderCat=replace(PreferedOrderCat,'Mobile','Mobile Phone') ; 
                         
 update customer_churn set PreferredPaymentMode=replace(PreferredPaymentMode,'COD','Cash ON Delivery'),  
                           PreferredPaymentMode=replace(PreferredPaymentMode,'CC','Credit Card') ;                    

## DATA TRANSFORMATION 

##Column Renaming

alter table  customer_churn rename column PreferedOrderCat TO PreferredOrderCat;
alter table  customer_churn rename column HourSpendOnApp TO HoursSpentOnApp;

## creating new column

alter table customer_churn add column ComplaintReceived varchar(3); 
update customer_churn set ComplaintReceived= case when Complain = 1 then 'Yes'else 'No'end;
alter table customer_churn add column ChurnStatus varchar(10);
update customer_churn set ChurnStatus=case when Churn=1 then 'Churned' else 'Active' end;

## column Dropping

alter table customer_churn drop column Complain; 
alter table customer_churn drop column Churn;

 ## Data Exploration and Analysis
 
select ChurnStatus, count(ChurnStatus) as count_of_ChurnStatus  from  customer_churn group by ChurnStatus;

select avg(Tenure),sum(CashbackAmount) from customer_churn where ChurnStatus="Churned";

SELECT (COUNT(CASE WHEN ChurnStatus = 'churned' AND ComplaintReceived = 'Yes' THEN CustomerID END) / COUNT(CASE WHEN ChurnStatus = 'churned' THEN CustomerID END)) * 100 AS percentage_churned_complained
FROM customer_churn;   

select CityTier,PreferredOrderCat,count(ChurnStatus) from customer_churn where ChurnStatus="Churned"  and PreferredOrderCat="Laptop & Accessory" group by CityTier
order by ChurnStatus desc limit 1;  
 
select PreferredPaymentMode,ChurnStatus,count(CustomerID) as Total_Customers from customer_churn where ChurnStatus="Active" 
group by  PreferredPaymentMode order by Total_Customers desc limit 1;

select PreferredOrderCat,MaritalStatus,sum(OrderAmountHikeFromlastYear) as Total_Order_Amount_Hike from customer_churn 
where MaritalStatus='Single' and PreferredOrderCat='Mobile Phone' 
group by  PreferredOrderCat,MaritalStatus ;

select avg(NumberOfDeviceRegistered) as Average_Number_of_Registered,PreferredPaymentMode from customer_churn where PreferredPaymentMode='UPI' ;

select  CityTier,count(CustomerID)  as Highest_Number_of_Customers from customer_churn group by CityTier order by  Highest_Number_of_Customers desc limit 1;

select Gender,count(CouponUsed)  as Highest_No_of_Coupons from customer_churn group by Gender order by Highest_No_of_Coupons desc limit 1;

select count(CustomerID) as number_of_Customers,max(HoursSpentOnApp) as Max_Hours_Spent,PreferredOrderCat from customer_churn group by PreferredOrderCat;

select count(OrderCount) as Total_Order_Count, max(SatisfactionScore) as Max_Satisfation_Score,PreferredPaymentMode from customer_churn where PreferredPaymentMode="Credit Card";

select avg(SatisfactionScore) as Average_Satisfation_Score from customer_churn where ComplaintReceived="Yes";

select PreferredOrderCat,CouponUsed from customer_churn where CouponUsed>5;

select PreferredOrderCat,avg(CashbackAmount) as HighestAvg_Cash_Back_Amount from customer_churn group by PreferredOrderCat order by HighestAvg_Cash_Back_Amount desc limit 3 ;

select PreferredPaymentMode,round (avg(Tenure)) as Average_Tenure,count(OrderCount) as Number_of_Orders from customer_churn  group by  PreferredPaymentMode  having round(avg(Tenure))=10 and count(OrderCount)>500;      

select  
case
when WarehouseToHome <=5 then 'Very Close Distance'
when WarehouseToHome <=10 then 'Close Distance'
when WarehouseToHome <=15 then 'Moderate Distance'
Else 'Far Distance'
End as Distance_category,ChurnStatus ,count(CustomerID) as Number_of_Customers from customer_churn  group by Distance_category,ChurnStatus;

select CustomerID,OrderCount, MaritalStatus,CityTier  from  customer_churn  where  MaritalStatus ='Married' and CityTier = 1 and OrderCount>(select avg(OrderCount) from customer_churn );          

create table Customer_Returns( ReturnID int primary key,CustomerID int,foreign key(CustomerID) references customer_churn(CustomerID), ReturnDate date,RefundAmount int);

insert into customer_Returns(ReturnID,CustomerID,ReturnDate,RefundAmount)
values(1001,50022,'2023-01-01',2130),
(1002,50316,'2023-01-23',2000),
(1003,51099,'2023-02-14',2290),
(1004,52321,'2023-03-08',2510),
(1005,52928,'2023-03-20',3000),
(1006,53749,'2023-04-17',1740),
(1007,54206,'2023-04-21',3250),
(1008,54838,'2023-04-30',1990);
select * from customer_returns;

select r.*,c.ChurnStatus,c.ComplaintReceived from customer_returns r left join customer_churn c on r.CustomerID=c.CustomerID
 where ChurnStatus="churned" and ComplaintReceived="Yes" ;













