|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

TASK 1 - ANALISI CATEGORIE

INFORMAZIONI DI BASE SUI PAESI:

-- Paesi che sono nostri clienti:
SELECT DISTINCT Country FROM Customers c WHERE Country NOT NULL;

-- Numero di paesi che sono nostri clienti:
SELECT COUNT(DISTINCT Country) FROM Customers c WHERE Country NOT NULL;

INFO DI BASE SU PRODOTTI E CATEGORIE:

-- TUTTE LE INFO SULLE CATEGORIE:
SELECT * FROM Categories c;
NUMERO DI CATEGORIE PRESENTI:
SELECT COUNT(*) AS NumberOfCategories FROM Categories c;

-- TUTTE LE INFO SUI PRODOTTI:
SELECT * FROM Products p;
NUMERO DI PRODOTTI:
SELECT COUNT(*) AS NumberOfProducts FROM Products p;

-- Numero prodotti per categoria:
SELECT c.CategoryID, c.CategoryName, COUNT(*) AS NumberOfProducts
FROM Categories c 
JOIN Products p ON c.CategoryID = p.CategoryID 
GROUP BY c.CategoryID;

-- Giacenza prodotti:
SELECT ProductID, ProductName, CategoryID, UnitsInStock 
FROM Products p;

-- Giacenza prodotti per categorie:
SELECT c.CategoryID, c.CategoryName, SUM(p.UnitsInStock) AS stock
FROM Categories c 
JOIN Products p ON c.CategoryID = p.CategoryID 
GROUP BY c.CategoryID;

-- Prezzo medio prodotti per categorie ordinato dal più alto al più basso:
SELECT c.CategoryID, c.CategoryName, AVG(p.UnitPrice) AS AvgPriceInCategory
FROM Categories c 
JOIN Products p ON c.CategoryID = p.CategoryID 
GROUP BY c.CategoryID
ORDER BY AvgPriceInCategory DESC;

-- Prezzo massimo prodotti per categorie ordinato dal più alto al più basso:
SELECT c.CategoryID, c.CategoryName, MAX(p.UnitPrice) AS MaxPriceInCategory
FROM Categories c 
JOIN Products p ON c.CategoryID = p.CategoryID 
GROUP BY c.CategoryID
ORDER BY MaxPriceInCategory DESC;

-- Prodotto più venduto per categoria:
SELECT p.ProductID, p.ProductName AS BestSellerInCategory, c.CategoryID, c.CategoryName, MAX(p.UnitsOnOrder) AS MaxUnitSold
FROM Categories c 
JOIN Products p ON c.CategoryID = p.CategoryID
-- WHERE p.UnitsOnOrder > 0
GROUP BY c.CategoryID, c.CategoryName;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INFORMAZIONI SULLE CATEGORIE VENDUTE PER PAESE:
TABELLE NECESSARIE: Categories(CategoryID) --> (CategoryID)Products(ProductID) --> (ProductID)Order Details(OrderID) --> (OrderID)Orders(CustomerID) --> (CustomerID)Customers 

-- Quantità di prodotti venduti per categorie ad ogni paese:

SELECT c.Country, ca.CategoryID, ca.CategoryName, SUM(od.Quantity) AS QuantitySold
FROM "Order Details" od 
JOIN Orders o ON od.OrderID = o.OrderID 
JOIN Customers c ON c.CustomerID = o.CustomerID 
JOIN Products p ON od.ProductID = p.ProductID 
JOIN Categories ca ON p.CategoryID = ca.CategoryID
GROUP BY c.Country, ca.CategoryID;

-- Fatturato totale per categorie in ogni paese:

SELECT c.Country,
       ca.CategoryID,
       ca.CategoryName,
       SUM(od.Quantity) AS QuantitySold,
       SUM(od.UnitPrice * od.Quantity) AS TotIncome
FROM "Order Details" od 
JOIN Orders o ON od.OrderID = o.OrderID 
JOIN Customers c ON c.CustomerID = o.CustomerID 
JOIN Products p ON od.ProductID = p.ProductID 
JOIN Categories ca ON p.CategoryID = ca.CategoryID
GROUP BY c.Country, ca.CategoryID;

-- Paesi che hanno acquistato da tutte le categorie:

WITH CustCatConnec AS(
SELECT c.Country,
ca.CategoryName
FROM Customers c 
	JOIN Orders o ON c.CustomerID = o.CustomerID 
		JOIN "Order Details" od on o.OrderID = od.OrderID 
			JOIN Products p ON od.ProductID = p.ProductID 
				JOIN Categories ca ON p.CategoryID = ca.CategoryID 
GROUP BY c.Country, ca.CategoryName 
ORDER BY c.Country 
)

SELECT CustCatConnec.Country
FROM CustCatConnec
GROUP BY CustCatConnec.Country
HAVING COUNT(*) = 8; (CAMBIARE LA CONDIZIONE NELLA HAVING DA = A <> PER OTTENERE I PAESI CHE NON HANNO ACQUISTATO DA TUTTE LE CATEGORIE)



-- Tutte le categorie da cui ha acquistato un paese:

SELECT ca.CategoryName
 FROM Customers c 
	JOIN Orders o ON c.CustomerID = o.CustomerID 
		JOIN "Order Details" od on o.OrderID = od.OrderID 
			JOIN Products p ON od.ProductID = p.ProductID 
				JOIN Categories ca ON p.CategoryID = ca.CategoryID 
WHERE c.Country = 'Argentina'
GROUP BY c.Country, ca.CategoryName;
(cambiando il Country nella WHERE si possono ottenere le informazioni sulle categorie da cui ha acquistato ogni paese)

-- Tutte le categorie da cui un paese non ha acquistato:

SELECT c.CategoryName 
FROM Categories c 
WHERE c.CategoryName NOT IN
(SELECT ca.CategoryName
 FROM Customers c 
	JOIN Orders o ON c.CustomerID = o.CustomerID 
		JOIN "Order Details" od on o.OrderID = od.OrderID 
			JOIN Products p ON od.ProductID = p.ProductID 
				JOIN Categories ca ON p.CategoryID = ca.CategoryID 
WHERE c.Country = 'Argentina'
GROUP BY c.Country, ca.CategoryName);

CON CTE(ED OPZIONALMENTE LEFT JOIN):

WITH cc AS
(SELECT ca.CategoryName
 FROM Customers c 
	JOIN Orders o ON c.CustomerID = o.CustomerID 
		JOIN "Order Details" od on o.OrderID = od.OrderID 
			JOIN Products p ON od.ProductID = p.ProductID 
				JOIN Categories ca ON p.CategoryID = ca.CategoryID 
WHERE c.Country = 'Argentina'
GROUP BY c.Country, ca.CategoryName)

SELECT c.CategoryName 
FROM Categories c 
--LEFT JOIN cc ON c.CategoryName = cc.CategoryName
WHERE c.CategoryName NOT IN cc;


|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
TASK 1 - ESTRARRE INSIGHTS SULLE NAZIONI A CUI VENDE L'AZIENDA

-- Prodotti venduti per paese, con ordinamento decrescente(dal paese a cui abbiamo venduto di più a quello a cui abbiamo venduto di meno)

SELECT SUM(od.Quantity) AS totale_prodotti, 
o.ShipCountry
FROM "Order Details" od 
INNER JOIN Orders o 
ON o.OrderID = od.OrderID 
GROUP BY o.ShipCountry 
ORDER BY SUM(od.Quantity) DESC

-- Revenue totale per paese
with total_revenue as ( 
select od.OrderID, SUM (od.UnitPrice*od.Quantity) AS total_revenue_per_order
from "Order Details" od
GROUP BY OrderID
)
select ShipCountry, SUM( tr.total_revenue_per_order ) as total_revenue_per_country
from total_revenue tr
join orders o ON o.OrderID = tr.OrderID
GROUP BY ShipCountry 
ORDER BY total_revenue_per_country DESC

-- Numero di ordini per paese
select o.ShipCountry, COUNT() as total_orders_country
from Orders o
group by ShipCountry


|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

TASK 2 - Calcolare l'ammontare delle vendite per l'azienda nei periodi 2016-2017-2018 utilizzando le tabelle Orders ed Orders Details.
         Separare i paesi in base all'ammontare delle vendite per 3 categorie: basso, medio e alto.                
         Decidere la soglia di ciascuna categoria in base alla distribuzione normale delle vendite e/o soglie empiriche giustificate in base ai dati


-- COMPANY REVENUES 2016(PER 2017 E 2018 BASTA CAMBIARE LA CONDIZIONE NELLA WHERE) CALCOLATI CON 3 DIVERSE, MA EQUIVALENTI, QUERY:
SELECT SUM(od.UnitPrice * od.Quantity) AS revenue_2016
FROM "Order Details" od 
JOIN Orders o on od.OrderID = o.OrderID 
WHERE o.OrderDate LIKE '2016%';

SELECT SUM(od.UnitPrice * od.Quantity) AS revenue_2016
FROM "Order Details" od 
JOIN Orders o on od.OrderID = o.OrderID 
WHERE o.OrderDate BETWEEN '2016-01-01' AND '2016-12-31';

SELECT SUM(od.UnitPrice * od.Quantity) AS revenue_2016
FROM "Order Details" od 
JOIN Orders o on od.OrderID = o.OrderID 
WHERE o.OrderDate >= '2016-01-01' AND o.OrderDate <= '2016-12-31';

NOTA: PER LE INFORMAZIONI ESTRATTE ERA SUFFICIENTE UTILIZZARE SOLTANTO LA TABELLA ORDER DETAILS.
      È POSSIBILE ESTRARRE INFORMAZIONI SULLE DATE E SUI PAESI MEDIANTE L'UTILIZZO DELLA TABELLA ORDERS (ATTRIBUTI ORDERDATE, SHIPCOUNTRY):

SELECT o.ShipCountry, o.OrderDate, od.UnitPrice,  od.Quantity
FROM "Order Details" od 
JOIN Orders o on od.OrderID = o.OrderID 
WHERE o.OrderDate LIKE '2016%'
ORDER BY o.OrderDate;

-- Revenue paese per data

SELECT o.ShipCountry, o.OrderDate, od.UnitPrice * od.Quantity AS Date_Revenue
FROM "Order Details" od 
JOIN Orders o on od.OrderID = o.OrderID 
WHERE o.OrderDate LIKE '2016%'
GROUP BY o.ShipCountry
ORDER BY o.OrderDate;

-- Revenue complessivo paese Anno 2016

SELECT o.ShipCountry, SUM(od.UnitPrice * od.Quantity) AS Tot_Revenue, SUBSTR(o.OrderDate, 1, 4) AS anno
FROM "Order Details" od 
JOIN Orders o on od.OrderID = o.OrderID 
WHERE o.OrderDate LIKE '2016%'
GROUP BY o.ShipCountry
ORDER BY o.OrderDate;

--------------------------------------------------------------------------------------------------------------------

-- Analisi vendite per paese negli anni 2016-2017-2018(separatamente) con threshold identificativo dell'andamento delle vendite:
(Per la realizzazione dei threshold abbiamo preso in considerazione il parametro revenue)

-- 2016
WITH T AS
(SELECT 
    c.Country, 
    SUM(od.UnitPrice * od.Quantity) AS revenue,
    substr(o.OrderDate,1,4) AS anno
 FROM "Order Details" od 
 JOIN Orders o ON od.OrderID = o.OrderID 
 JOIN Customers c on o.CustomerID=c.CustomerID 
 WHERE o.OrderDate LIKE '2016%'
 GROUP BY c.Country )
 
SELECT 
    T.Country, 
    revenue, anno,
CASE WHEN revenue < (select (max(revenue*0.35)) from T) THEN 'LOW'   -- se la revenue del paese è < TOT% MAX(revenue_2018) -> LOW   -> TOT% = 35%MAX
     WHEN revenue < (select (max(revenue*0.75)) from T) THEN 'MEDIUM' --  se la revenue del paese è < TOT1% MAX(revenue 2018) -> MEDIUM -> TOT% = 75%MAX
     ELSE 'HIGH'
     END AS THRESHOLD
FROM T
ORDER BY revenue

-- 2017
WITH T AS
(SELECT 
    c.Country, 
    SUM(od.UnitPrice * od.Quantity) AS revenue,
    substr(o.OrderDate,1,4) AS anno
 FROM "Order Details" od 
 JOIN Orders o ON od.OrderID = o.OrderID 
 JOIN Customers c on o.CustomerID=c.CustomerID 
 WHERE o.OrderDate LIKE '2017%'
 GROUP BY c.Country )
 
SELECT 
    T.Country, 
    revenue, anno,
CASE WHEN revenue < (select (max(revenue*0.35)) from T) THEN 'LOW'   -- se la revenue del paese è < TOT% MAX(revenue_2018) -> LOW   -> TOT% = 35%MAX
     WHEN revenue < (select (max(revenue*0.75)) from T) THEN 'MEDIUM' --  se la revenue del paese è < TOT1% MAX(revenue 2018) -> MEDIUM -> TOT% = 75%MAX
     ELSE 'HIGH'
     END AS THRESHOLD
FROM T
ORDER BY revenue

--2018
WITH T AS
(SELECT 
    c.Country, 
    SUM(od.UnitPrice * od.Quantity) AS revenue,
    substr(o.OrderDate,1,4) AS anno
 FROM "Order Details" od 
 JOIN Orders o ON od.OrderID = o.OrderID 
 JOIN Customers c on o.CustomerID=c.CustomerID 
 WHERE o.OrderDate LIKE '2018%'
 GROUP BY c.Country )
 
SELECT 
    T.Country, 
    t.revenue,
    anno,
CASE WHEN revenue < (select (max(revenue*0.35)) from T) THEN 'LOW'   -- se la revenue del paese è < TOT% MAX(revenue_2018) -> LOW   -> TOT% = 35%MAX
     WHEN revenue < (select (max(revenue*0.75)) from T) THEN 'MEDIUM' --  se la revenue del paese è < TOT1% MAX(revenue 2018) -> MEDIUM -> TOT% = 75%MAX
     ELSE 'HIGH'
     END AS THRESHOLD
FROM T
ORDER BY revenue

P.S.:
Abbiamo notato che i periodi di riferimento inseriti nel Database circa le revenue dei singoli anni differiscono tra loro in modo sostanziale.
Per l'anno 2016, il periodo di riferimento va da 04/07/2016 al 31/12/2016.
Per l'anno 2017, il periodo di riferimento va da 01/01/2017 al 31/12/2017.
Per l'anno 2018, il periodo di riferimento va da 01/01/2018 al 06/05/2018.

Per ovviare a questa discrepanza, abbiamo pensato di creare un criterio sfruttando la variazione del massimo della revenue affidandoci ad un rapporto
percentuale, in modo tale da creare un set di threshold che in autonomia si adatta alla variazione dei dati.

se la revenue del paese è < TOT% MAX(revenue_2018) -> LOW   -> TOT% = 35%MAX
se la revenue del paese è < TOT1% MAX(revenue 2018) -> MEDIUM -> TOT% = 75%MAX


|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

TASK 3 - Top 3 prodotti venduti

Top 3 prodotti venduti in generale, notando in particolare la categoria del prodotto:
SELECT p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, SUM(od.Quantity) AS Total 
FROM Products p 
JOIN "Order Details" od  ON p.ProductID = od.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID 
GROUP BY p.ProductID
ORDER BY Total DESC 
LIMIT 3

-- 2016,2017,2018 ( NOTIAMO CHE IL CAMEMBERT PIERROT rientra nelle top 3 per ogni anno )
-- Top 3 prodotti più venduti / ordinati complessivamente per anno, con categoria:
SELECT p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, SUM(od.Quantity) AS Total,
SUBSTR(o.OrderDate, 1, 4) AS anno 
FROM Products p 
JOIN "Order Details" od  ON p.ProductID = od.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID 
JOIN Orders o ON od.OrderID = o.OrderID 
WHERE o.OrderDate LIKE '2016%'
GROUP BY p.ProductID
ORDER BY Total DESC 
LIMIT 3

-- top 3 prodotti per revenue, con categoria:
SELECT p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, SUM(od.Quantity * od.UnitPrice) AS revenue
FROM Products p 
JOIN "Order Details" od  ON p.ProductID = od.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID 
GROUP BY p.ProductID
ORDER BY revenue DESC 
LIMIT 3

-- top 3 prodotti per paese in base alla revenue totale ( Cote de la blaye dominio totale ):
SELECT p.ProductID, p.ProductName, p.CategoryID, c.CategoryName, SUM(od.Quantity * od.UnitPrice) AS revenue
FROM Products p 
JOIN "Order Details" od  ON p.ProductID = od.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID 
GROUP BY p.ProductID
ORDER BY revenue DESC 
LIMIT 3


|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


TASK 4:
(1) Genera un rapporto sul numero di territori di cui ogni dipendente è responsabile.
(2) Genera un rapporto sul rendimento dei dipendenti in base all'importo delle vendite e ordinali in ordine decrescente.
(3) Confronta i due rapporti.


(1)
-- Genera un rapporto sul numero di territori di cui ogni dipendente è responsabile.

-- NUMERO DI TERRITORI DI CUI OGNI DIPENDENTE(EMPLOYEE) È RESPONSABILE

SELECT 
	et.EmployeeID, 
	e.LastName, 
	e.FirstName, 
	e.Country,
	COUNT(TerritoryID) AS NumTerrResp
FROM EmployeeTerritories et 
JOIN Employees e ON et.EmployeeID = e.EmployeeID 
GROUP BY et.EmployeeID;

P.S.: La colonna e.Country mostra il paese di provenienza del dipendente


(2)
-- Genera un rapporto sul rendimento dei dipendenti in base all'importo delle vendite e ordinali in ordine decrescente.

SELECT 
	e.EmployeeID, 
	e.LastName, 
	e.FirstName,
	e.Country,
	ROUND(SUM(Quantity * UnitPrice)) AS SalesAmount
FROM Employees e 
JOIN Orders o ON e.EmployeeID = o.EmployeeID 
JOIN "Order Details" od ON o.OrderID = od.OrderID 
GROUP BY e.EmployeeID 
ORDER BY SalesAmount DESC;

-- Fatturato e NumTerrResp a confronto, con info sulla Region

WITH NumTerrTable AS
(SELECT 
	et.EmployeeID, 
	e.LastName, 
	e.FirstName, 
	e.Country,
	COUNT(TerritoryID) AS NumTerrResp
FROM EmployeeTerritories et 
JOIN Employees e ON et.EmployeeID = e.EmployeeID 
GROUP BY et.EmployeeID
),
EmployeePerformance AS
(SELECT 
	e.EmployeeID, 
	e.LastName, 
	e.FirstName,
	e.Country,
	ROUND(SUM(Quantity * UnitPrice)) AS SalesAmount
FROM Employees e 
JOIN Orders o ON e.EmployeeID = o.EmployeeID 
JOIN "Order Details" od ON o.OrderID = od.OrderID 
GROUP BY e.EmployeeID 
ORDER BY SalesAmount DESC
 ),
 EmployeeRegion AS
 (SELECT 
	DISTINCT et.EmployeeID,
	r.RegionDescription 
 FROM Regions r 
 JOIN Territories t  ON r.RegionID = t.RegionID 
 JOIN EmployeeTerritories et ON t.TerritoryID = et.TerritoryID 
 )

SELECT 
	nt.EmployeeID, 
	nt.LastName, 
	nt.FirstName,
	nt.Country,
	nt.NumTerrResp,
	er.RegionDescription,
	ep.SalesAmount
FROM NumTerrTable nt
JOIN EmployeePerformance ep ON nt.EmployeeID = ep.EmployeeID
JOIN EmployeeRegion er ON ep.EmployeeID = er.EmployeeID
ORDER BY nt.NumTerrResp DESC;


-- Relativamente alla regione, a parità di territori, chi è più performante tra USA e UK

WITH NumTerrTable AS
(SELECT 
	et.EmployeeID, 
	e.LastName, 
	e.FirstName, 
	e.Country,
	COUNT(TerritoryID) AS NumTerrResp
FROM EmployeeTerritories et 
JOIN Employees e ON et.EmployeeID = e.EmployeeID 
GROUP BY et.EmployeeID
),
EmployeePerformance AS
(SELECT 
	e.EmployeeID, 
	e.LastName, 
	e.FirstName,
	e.Country,
	ROUND(SUM(Quantity * UnitPrice)) AS SalesAmount
FROM Employees e 
JOIN Orders o ON e.EmployeeID = o.EmployeeID 
JOIN "Order Details" od ON o.OrderID = od.OrderID 
GROUP BY e.EmployeeID 
ORDER BY SalesAmount DESC
 ),
 EmployeeRegion AS
 (SELECT 
	DISTINCT et.EmployeeID,
	r.RegionDescription 
 FROM Regions r 
 JOIN Territories t  ON r.RegionID = t.RegionID 
 JOIN EmployeeTerritories et ON t.TerritoryID = et.TerritoryID 
 ),
RiassumingTable AS
( 
SELECT 
	nt.EmployeeID, 
	nt.LastName, 
	nt.FirstName,
	nt.Country,
	nt.NumTerrResp,
	er.RegionDescription,
	ep.SalesAmount
FROM NumTerrTable nt
JOIN EmployeePerformance ep ON nt.EmployeeID = ep.EmployeeID
JOIN EmployeeRegion er ON ep.EmployeeID = er.EmployeeID
ORDER BY nt.NumTerrResp DESC
)

SELECT 
	rt1.EmployeeID, 
	rt1.LastName, 
	rt1.FirstName,
	rt1.Country,
	rt1.NumTerrResp,
	rt1.RegionDescription,
	rt1.SalesAmount
FROM RiassumingTable rt1, RiassumingTable rt2
WHERE rt1.NumTerrResp = rt2.NumTerrResp AND rt1.RegionDescription = rt2.RegionDescription
AND rt1.EmployeeID <> rt2.EmployeeID


-- Numero di ordini e fatturato totale per paese di provenienza
SELECT 
	e.Country, 
	COUNT (o.OrderID) as OrderCount, 
	ROUND(SUM(od.Quantity*od.UnitPrice),2) as TotalSales
from Employees e
left join Orders o on e.EmployeeID =o.EmployeeID 
join "Order Details" od on o.OrderID = od.OrderID 
group by e.Country 
order by ordercount desc;


-- Figure ( Title ) presenti in USA ma non presenti in UK
SELECT e.Title AS OnlyUSAtitles
FROM Employees e
WHERE e.Country = 'USA'
AND e.Title NOT IN 
(SELECT e2.Title FROM Employees e2 WHERE e2.Country = 'UK')

-- Confronto età medie dipendenti USA vs UK
SELECT e.Country, AVG(DATETIME('now')  - e.BirthDate) AS AvgAge
FROM Employees e 
GROUP BY e.Country;


|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||


TASK 5:

(1) Determinare la categoria di prodotti spedita nelle regioni a bassa vendita.
(2) Calcolare la data media di spedizione per ogni categoria nelle regioni a bassa vendita e confrontala con la data di spedizione richiesta.
(3) Calcolare gli effetti dello sconto nelle regioni a bassa vendita rispetto alle regioni ad alta vendita.


(1) 
-- categorie e prodotti venduti nei paesi a bassa vendita
-- Informazioni aggregate per paese e categoria

SELECT o.ShipCountry, c.CategoryID, c.CategoryName, ROUND(SUM(od.UnitPrice * od.Quantity)) AS total_revenues_in_category_per_country
FROM Categories c 
	JOIN Products p ON c.CategoryID = p.CategoryID 
		JOIN "Order Details" od ON p.ProductID = od.ProductID 
			JOIN Orders o ON od.OrderID = o.OrderID 
WHERE o.ShipCountry IN
(WITH country_revenues_table AS
(SELECT 
    o.ShipCountry , 
    SUM(od.UnitPrice * od.Quantity) AS country_revenue_triennale
 FROM "Order Details" od 
 	JOIN Orders o ON od.OrderID = o.OrderID 
 GROUP BY o.ShipCountry),
low_revenues_country_table AS 
(SELECT 
    crt.ShipCountry, 
    crt.country_revenue_triennale,
	CASE 
		WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.20)) FROM country_revenues_table) THEN 'LOW'   -- se la revenue del paese è < TOT% MAX(revenue_triennale) -> LOW   -> TOT% = 20%MAX
	    WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.50)) FROM country_revenues_table) THEN 'MEDIUM' --  se la revenue del paese è < TOT% MAX(revenue_triennale) -> MEDIUM -> TOT% = 50%MAX
	    ELSE 'HIGH'
	    END AS THRESHOLD
 FROM country_revenues_table crt
 WHERE THRESHOLD = 'LOW'
 ORDER BY country_revenue_triennale)
SELECT lrct.ShipCountry
FROM low_revenues_country_table lrct)
GROUP BY o.ShipCountry, c.CategoryID
-- ORDER BY o.ShipCountry, total_revenues_in_category_per_country DESC

(2)

--RIFERIMENTO :  data ordine > data spedizione > data richiesta ( il prodotto deve essere consegnato )

-- Data spedizione - Data Ordine = TimeToProcess ( tempo per evasione fisica dell'ordine )
-- Data Richiesta - Data Ordine  = TimeToEvade ( dall'ordine alla data richiesta dal cliente )

WITH tt AS 
(select 
	c.CategoryID, 
	c.CategoryName, 
	o.ShipCountry, 
	JULIANDAY(RequiredDate)-JULIANDAY(OrderDate) as timeToEvade, 
	JULIANDAY(ShippedDate)-JULIANDAY(OrderDate) AS timeToProcess
FROM Orders o
JOIN "Order Details" od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE o.ShipCountry  IN (WITH country_revenues_table AS
(SELECT 
    o.ShipCountry , 
    SUM(od.UnitPrice * od.Quantity) AS country_revenue_triennale
 FROM "Order Details" od 
 	JOIN Orders o ON od.OrderID = o.OrderID 
 GROUP BY o.ShipCountry),
low_revenues_country_table AS 
(SELECT 
    crt.ShipCountry, 
    crt.country_revenue_triennale,
	CASE 
		WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.20)) FROM country_revenues_table) THEN 'LOW'   -- se la revenue del paese è < TOT% MAX(revenue_triennale) -> LOW   -> TOT% = 20%MAX
	    WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.50)) FROM country_revenues_table) THEN 'MEDIUM' --  se la revenue del paese è < TOT% MAX(revenue_triennale) -> MEDIUM -> TOT% = 50%MAX
	    ELSE 'HIGH'
	    END AS THRESHOLD
 FROM country_revenues_table crt
 WHERE THRESHOLD = 'LOW'
 ORDER BY country_revenue_triennale)
SELECT lrct.ShipCountry
FROM low_revenues_country_table lrct)
ORDER BY c.CategoryID)

SELECT 
	tt.CategoryID, 
	tt.CategoryName,
	tt.ShipCountry, 
	tt.timeToEvade, 
	tt.timeToProcess, 
CASE
	WHEN tt.timeToEvade > tt.timeToProcess THEN "On time"
	ELSE "Delayed"
END AS "Status"
from tt


-- AVG(ShipDate-OrderDate) per ogni categoria nei paese a bassa vendita - Tempo medio per processare gli ordini in base alla categoria

SELECT 
	c.CategoryName, 
	CEIL(AVG(JULIANDAY(ShippedDate)-JULIANDAY(OrderDate))) AS AverageTimetoProcess
FROM Orders o
JOIN "Order Details" od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE o.ShipCountry  IN (WITH country_revenues_table AS
(SELECT 
    o.ShipCountry , 
    SUM(od.UnitPrice * od.Quantity) AS country_revenue_triennale
 FROM "Order Details" od 
 	JOIN Orders o ON od.OrderID = o.OrderID 
 GROUP BY o.ShipCountry),
low_revenues_country_table AS 
(SELECT 
    crt.ShipCountry, 
    crt.country_revenue_triennale,
	CASE 
		WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.20)) FROM country_revenues_table) THEN 'LOW'   -- se la revenue del paese è < TOT% MAX(revenue_triennale) -> LOW   -> TOT% = 20%MAX
	    WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.50)) FROM country_revenues_table) THEN 'MEDIUM' --  se la revenue del paese è < TOT% MAX(revenue_triennale) -> MEDIUM -> TOT% = 50%MAX
	    ELSE 'HIGH'
	    END AS THRESHOLD
 FROM country_revenues_table crt
 WHERE THRESHOLD = 'LOW'
 ORDER BY country_revenue_triennale)
SELECT lrct.ShipCountry
FROM low_revenues_country_table lrct)
GROUP BY c.CategoryName;

-- AVG(ReqDate-OrderDate) per ogni categoria nei paese a bassa vendita - tempo medio per evadere gli ordini in base alla categoria

SELECT c.CategoryName, CEIL(AVG(JULIANDAY(RequiredDate)-JULIANDAY(OrderDate))) AS AverageTimeToEvade
FROM Orders o
JOIN "Order Details" od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE o.ShipCountry  IN (WITH country_revenues_table AS
(SELECT 
    o.ShipCountry , 
    SUM(od.UnitPrice * od.Quantity) AS country_revenue_triennale
 FROM "Order Details" od 
 	JOIN Orders o ON od.OrderID = o.OrderID 
 GROUP BY o.ShipCountry),
low_revenues_country_table AS 
(SELECT 
    crt.ShipCountry, 
    crt.country_revenue_triennale,
	CASE 
		WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.20)) FROM country_revenues_table) THEN 'LOW'   -- se la revenue del paese è < TOT% MAX(revenue_triennale) -> LOW   -> TOT% = 20%MAX
	    WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.50)) FROM country_revenues_table) THEN 'MEDIUM' --  se la revenue del paese è < TOT% MAX(revenue_triennale) -> MEDIUM -> TOT% = 50%MAX
	    ELSE 'HIGH'
	    END AS THRESHOLD
 FROM country_revenues_table crt
 WHERE THRESHOLD = 'LOW'
 ORDER BY country_revenue_triennale)
SELECT lrct.ShipCountry
FROM low_revenues_country_table lrct)
GROUP BY c.CategoryName;

P.S.: Abbiamo deciso di utilizzare la funzione CEIL per approssimare sempre per eccesso i tempi di evasione degli ordini e rimanere in una situazione più "conservativa"

(3) 

-- Effetto sconti paesi bassa vendita

SELECT 
	o.ShipCountry, 
	ROUND(SUM(od.UnitPrice * od.Quantity)) AS total_revenues_per_country,
	ROUND(SUM(od.UnitPrice * od.Quantity) - SUM(od.UnitPrice * od.Quantity * od.Discount)) AS total_revenues_per_country_with_discount
FROM Categories c 
	JOIN Products p ON c.CategoryID = p.CategoryID 
		JOIN "Order Details" od ON p.ProductID = od.ProductID 
			JOIN Orders o ON od.OrderID = o.OrderID 
WHERE o.ShipCountry IN
(WITH country_revenues_table AS
(SELECT 
    o.ShipCountry , 
    SUM(od.UnitPrice * od.Quantity) AS country_revenue_triennale
 FROM "Order Details" od 
 	JOIN Orders o ON od.OrderID = o.OrderID 
 GROUP BY o.ShipCountry),
low_revenues_country_table AS 
(SELECT 
    crt.ShipCountry, 
    crt.country_revenue_triennale,
	CASE 
		WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.20)) FROM country_revenues_table) THEN 'LOW'   -- se la revenue del paese è < TOT% MAX(revenue_triennale) -> LOW   -> TOT% = 20%MAX
	    WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.50)) FROM country_revenues_table) THEN 'MEDIUM' --  se la revenue del paese è < TOT% MAX(revenue_triennale) -> MEDIUM -> TOT% = 50%MAX
	    ELSE 'HIGH'
	    END AS THRESHOLD
 FROM country_revenues_table crt
 WHERE THRESHOLD = 'LOW'
 ORDER BY country_revenue_triennale)
SELECT lrct.ShipCountry
FROM low_revenues_country_table lrct)
GROUP BY o.ShipCountry


-- Effetto sconti paesi ad alta vendita

SELECT 
	o.ShipCountry, 
	ROUND(SUM(od.UnitPrice * od.Quantity)) AS total_revenues_per_country,
	ROUND(SUM(od.UnitPrice * od.Quantity) - SUM(od.UnitPrice * od.Quantity * od.Discount)) AS total_revenues_per_country_with_discount
FROM Categories c 
	JOIN Products p ON c.CategoryID = p.CategoryID 
		JOIN "Order Details" od ON p.ProductID = od.ProductID 
			JOIN Orders o ON od.OrderID = o.OrderID 
WHERE o.ShipCountry IN
(WITH country_revenues_table AS
(SELECT 
    o.ShipCountry , 
    SUM(od.UnitPrice * od.Quantity) AS country_revenue_triennale
 FROM "Order Details" od 
 	JOIN Orders o ON od.OrderID = o.OrderID 
 GROUP BY o.ShipCountry),
low_revenues_country_table AS 
(SELECT 
    crt.ShipCountry, 
    crt.country_revenue_triennale,
	CASE 
		WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.20)) FROM country_revenues_table) THEN 'LOW'   -- se la revenue del paese è < TOT% MAX(revenue_triennale) -> LOW   -> TOT% = 20%MAX
	    WHEN country_revenue_triennale < (SELECT (MAX(country_revenue_triennale*0.50)) FROM country_revenues_table) THEN 'MEDIUM' --  se la revenue del paese è < TOT% MAX(revenue_triennale) -> MEDIUM -> TOT% = 50%MAX
	    ELSE 'HIGH'
	    END AS THRESHOLD
 FROM country_revenues_table crt
 WHERE THRESHOLD = 'HIGH'
 ORDER BY country_revenue_triennale)
SELECT lrct.ShipCountry
FROM low_revenues_country_table lrct)
GROUP BY o.ShipCountry
 