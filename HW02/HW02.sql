/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

select	
		StockItemID [ИД товара], 
		StockItemName [Наименование товара]
from	Warehouse.StockItems
where	StockItemName like '%urgent%' 
		or StockItemName like 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

select 
		ps.SupplierID [ИД поставщика], 
		ps.SupplierName [Наименование поставщика]
from	Purchasing.Suppliers ps
		left join Purchasing.PurchaseOrders pso on ps.SupplierID = pso.SupplierID
where	pso.SupplierID is Null

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select  so.OrderID [OrderID], 
		format (so.OrderDate, 'dd.MM.yyyy') [Дата заказа],
		datename (month, so.OrderDate) [Название месяца],
		datepart (quarter, so.OrderDate) [Номер квартала],
		sc.CustomerName [Имя клиента] 
from	Sales.Orders so
		join Sales.Customers sc on so.CustomerID = sc.CustomerID
		join Sales.OrderLines sol on so.OrderID = sol.OrderID
		join Warehouse.StockItems wsi on wsi.StockItemID = sol.StockItemID
where	(sol.UnitPrice > 100 or sol.Quantity > 20) and sol.PickingCompletedWhen is not Null
order by datepart (quarter, so.OrderDate) asc, format (so.OrderDate, 'dd.MM.yyyy') asc


declare @pagesize	bigint = 100,
		@pagenum	bigint = 11


select  so.OrderID [OrderID], 
		format (so.OrderDate, 'dd.MM.yyyy') [Дата заказа],
		datename (month, so.OrderDate) [Название месяца],
		datepart (quarter, so.OrderDate) [Номер квартала],
		sc.CustomerName [Имя клиента] 
from	Sales.Orders so
		join Sales.Customers sc on so.CustomerID = sc.CustomerID
		join Sales.OrderLines sol on so.OrderID = sol.OrderID
		join Warehouse.StockItems wsi on wsi.StockItemID = sol.StockItemID
where	(sol.UnitPrice > 100 or sol.Quantity > 20) and sol.PickingCompletedWhen is not Null
order by datepart (quarter, so.OrderDate) asc, format (so.OrderDate, 'dd.MM.yyyy') asc offset (@pagenum-1) * @pagesize rows
fetch next @pagesize rows only

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

select 
		adm.DeliveryMethodName [Способ доставки], 
		ppo.ExpectedDeliveryDate [Дата доставки], 
		ps.SupplierName [Имя поставщика], 
		ap.FullName [Имя контактного лица принимавшего заказ] 
from	Purchasing.PurchaseOrders ppo
		join Application.DeliveryMethods adm on ppo.DeliveryMethodID = adm.DeliveryMethodID 
												and adm.DeliveryMethodName in ('Air Freight', 'Refrigerated Air Freight')
		join Application.People ap on ap.PersonID = ppo.ContactPersonID
		join Purchasing.Suppliers ps on ps.SupplierID = ppo.SupplierID
where	ppo.ExpectedDeliveryDate >= '20130101' 
		and ppo.ExpectedDeliveryDate < '20130201' 
		and ppo.IsOrderFinalized = 1 
/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

select top 10 
		sc1.CustomerName [Имя клиента], 
		sc2.CustomerName [Имя сотрудника]
from	Sales.Orders so
		join Sales.Customers sc1 on sc1.CustomerID = so.CustomerID
		join Sales.Customers sc2 on sc2.CustomerID = so.SalespersonPersonID
order by so.OrderDate desc

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

select 
		sc.CustomerID [ID клиента], 
		sc.CustomerName [Имя клиента], 
		sc.PhoneNumber [Контактный телефон]
from	Sales.Orders so
		join Sales.Customers sc on so.CustomerID = sc.CustomerID
		join Sales.OrderLines sol on so.OrderID = sol.OrderID
		join Warehouse.StockItems wsi on wsi.StockItemID = sol.StockItemID
where	wsi.StockItemName = 'Chocolate frogs 250g'
