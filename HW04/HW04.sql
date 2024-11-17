/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

select distinct ap.PersonID, ap.SearchName from Application.People ap
left join Sales.Invoices si on si.SalespersonPersonID = ap.PersonID and si.InvoiceDate = '20150704'
where ap.IsSalesPerson = 1 and si.SalespersonPersonID is null

with 
a as (
select SalespersonPersonID from Sales.Invoices where InvoiceDate = '20150704'
)
select ap.PersonID, ap.SearchName from Application.People ap
left join a on a.SalespersonPersonID = ap.PersonID
where ap.IsSalesPerson = 1 and a.SalespersonPersonID is null

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

select distinct StockItemID, Description, UnitPrice from Sales.OrderLines sol
where UnitPrice in (select min (UnitPrice) from Sales.OrderLines sol )

select distinct StockItemID, Description, UnitPrice, (select min (UnitPrice) from Sales.OrderLines sol)  as MinPrice
from Sales.OrderLines sol1

select StockItemID, Description, min (UnitPrice) from Sales.OrderLines sol group by StockItemID, Description, UnitPrice order by UnitPrice
/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

with 
a as (
select  top 5 CustomerID, TransactionAmount from Sales.CustomerTransactions order by TransactionAmount desc
)
select sc.CustomerID, sc.CustomerName from Sales.Customers sc
join a on a.CustomerID = sc.CustomerID

select sc.CustomerID, sc.CustomerName from Sales.Customers sc
join Sales.CustomerTransactions sct on sc.CustomerID = sct.CustomerID
where sct.TransactionAmount in (select top 5 TransactionAmount from Sales.CustomerTransactions order by TransactionAmount desc)
order by TransactionAmount desc

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

select distinct ac.CityID, ac.CityName, ssc2.CustomerName 
from Sales.OrderLines so1
join (select distinct top 3 UnitPrice, StockItemID
from Sales.OrderLines 
order by  UnitPrice desc) so2 on so1.StockItemID = so2.StockItemID
join Sales.Invoices si on so1.OrderID = si.OrderID
join Sales.Customers ssc1 on si.CustomerID = ssc1.CustomerID
join Sales.Customers ssc2 on si.PackedByPersonID = ssc2.CustomerID
join Application.Cities ac on ac.CityID = ssc1.DeliveryCityID


