

-- Посчитать среднюю цену товара, общую сумму продажи по месяцам.
select datepart (year, so.OrderDate) [Год], 
	   datename (month, so.OrderDate) [Месяц], 
	   avg (sol.UnitPrice) [Средняя цена товара], 
	   sum (sol.Quantity*sol.UnitPrice) [Сумма продаж]
from Sales.Orders so
join Sales.OrderLines sol on so.OrderID = sol.OrderID
group by datename (month, so.OrderDate), datepart (year, so.OrderDate)

-- Отобразить все месяцы, где общая сумма продаж превысила 4 600 000.
select datename (month, so.OrderDate) [Месяц]
from Sales.Orders so
join Sales.OrderLines sol on so.OrderID = sol.OrderID
group by datename (month, so.OrderDate), datepart (year, so.OrderDate)
having sum (sol.Quantity*sol.UnitPrice) > 4600000
order by datepart (year, so.OrderDate), datename (month, so.OrderDate)
-- или подробно
select datepart (year, so.OrderDate) [Год], 
	   datename (month, so.OrderDate) [Месяц], 
	   avg (sol.UnitPrice) [Средняя цена товара], 
	   sum (sol.Quantity*sol.UnitPrice) [Сумма продаж]
from Sales.Orders so
join Sales.OrderLines sol on so.OrderID = sol.OrderID
group by datename (month, so.OrderDate), datepart (year, so.OrderDate)
having sum (sol.Quantity*sol.UnitPrice) > 4600000
order by datepart (year, so.OrderDate), datename (month, so.OrderDate)

-- Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц. Группировка должна быть по году, месяцу, товару.

select sum (sol.Quantity*sol.UnitPrice) [Сумма продаж],
	   min (so.OrderDate) [День первой продажи], 
	   sum (sol.Quantity) [Количество проданного товара]
from Sales.Orders so
join Sales.OrderLines sol on so.OrderID = sol.OrderID
group by datename (month, so.OrderDate), datepart (year, so.OrderDate), sol.StockItemID
having sum (sol.Quantity) < 50
order by datepart (year, so.OrderDate), datename (month, so.OrderDate)



select case when sum (sol.Quantity) < 50 then sum (sol.Quantity)
	   else '0' end [Количество проданного товара]
from Sales.Orders so
join Sales.OrderLines sol on so.OrderID = sol.OrderID
group by datename (month, so.OrderDate), datepart (year, so.OrderDate), sol.StockItemID
--having sum (sol.Quantity) < 50
order by datepart (year, so.OrderDate), datename (month, so.OrderDate)




