
---- Criação do Banco ----
CREATE DATABASE sales_superstore

---- Se necessário deletar tabelas

DROP TABLE IF EXISTS stage_orders;
DROP TABLE IF EXISTS stage_people;
DROP TABLE IF EXISTS stage_returns;

---- Criando as tabelas de stage para o carregamento dos dados do Excel ----

CREATE TABLE stage_orders (
    Row_ID TEXT, Order_ID TEXT, Order_Date TEXT, Ship_Date TEXT,
    Ship_Mode TEXT, Customer_ID TEXT, Customer_Name TEXT, Segment TEXT,
    Country TEXT, City TEXT, State_Province TEXT, Postal_Code TEXT,
    Region TEXT, Product_ID TEXT, Category TEXT, Sub_Category TEXT,
    Product_Name TEXT, Sales TEXT, Quantity TEXT, Discount TEXT, Profit TEXT
);

CREATE TABLE stage_people (
    Regional_Manager TEXT, Region TEXT
);

CREATE TABLE stage_returns (
    Returned TEXT, Order_ID TEXT
);

---- Puxando dados dos .csvs gerados ----

-- orders.csv, people.csv, returns.csv

COPY stage_orders FROM '/tmp/orders.csv' DELIMITER ';'
CSV header WHERE (Row_ID IS NOT NULL AND TRIM(Row_ID) != '');

COPY stage_people FROM '/tmp/people.csv' DELIMITER ';' CSV HEADER;

COPY stage_returns FROM '/tmp/returns.csv' DELIMITER ';' CSV HEADER;

---- Criação das tabelas dimensão e fato ----

CREATE TABLE dim_customer (
    Customer_ID VARCHAR(50) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50)
);

CREATE TABLE dim_product (
    Product_ID VARCHAR(50) PRIMARY KEY,
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(200)
);

CREATE TABLE dim_address (
    Address_ID SERIAL PRIMARY KEY,
    Country VARCHAR(50),
    City VARCHAR(50),
    State_Province VARCHAR(50),
    Postal_Code VARCHAR(20)
);

CREATE TABLE dim_order (
    Order_ID VARCHAR(50) PRIMARY KEY,
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Region VARCHAR(30)
);

CREATE TABLE dim_people(
	People_ID SERIAL PRIMARY KEY,
    Region VARCHAR(30),
    Regional_Manager VARCHAR(100)
);

CREATE TABLE dim_returns (
    Order_ID VARCHAR(50) PRIMARY KEY,
    Returned VARCHAR(3)
);

CREATE TABLE fact_sales(
    Row_ID INT PRIMARY KEY,
    Order_ID VARCHAR(50),
    Customer_ID VARCHAR(50),
    Product_ID VARCHAR(50),
    Address_ID INT,
    Sales DECIMAL(12,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(12,2),
    FOREIGN KEY (Order_ID) REFERENCES dim_order(Order_ID),
    FOREIGN KEY (Customer_ID) REFERENCES dim_customer(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES dim_product(Product_ID),
    FOREIGN KEY (Address_ID) REFERENCES dim_address(Address_ID)
);


---- TRATAMENTO DE DADOS ----


-- FUNÇÕES UTILIZADAS

CREATE OR REPLACE FUNCTION fn_padronizar_region(reg TEXT)
RETURNS VARCHAR(30) AS $$
BEGIN
    RETURN CASE 
        WHEN UPPER(TRIM(reg)) IN ('CENTRAL', 'CENTRAL REGION', 'CTR', 'CENTRAL REGION', 'CENTRAL REGION') THEN 'Central'
        WHEN UPPER(TRIM(reg)) IN ('EAST', 'EAST REGION', 'EAS T', 'EASTERN') THEN 'East'
        WHEN UPPER(TRIM(reg)) IN ('SOUTH', 'SOUTH REGION', 'SOUTH ', 'SOUTH REGION', 'STH') THEN 'South'
        WHEN UPPER(TRIM(reg)) IN ('WEST', 'WEST REGION', 'WESTERN', 'WST') THEN 'West'
        ELSE 'Other'
    END;
END;
$$ LANGUAGE plpgsql IMMUTABLE

CREATE OR REPLACE FUNCTION parse_date(data_texto TEXT)
RETURNS DATE AS $$
DECLARE
    data_convertida DATE;
BEGIN
    -- Tentar diferentes formatos
    BEGIN
        -- Tenta MM/DD/YYYY
        data_convertida := TO_DATE(data_texto, 'MM/DD/YYYY');
        RETURN data_convertida;
    EXCEPTION WHEN OTHERS THEN
        BEGIN
            -- Tenta DD/MM/YYYY
            data_convertida := TO_DATE(data_texto, 'DD/MM/YYYY');
            RETURN data_convertida;
        EXCEPTION WHEN OTHERS THEN
            BEGIN
                -- Tenta Mon DD YYYY (ex: Feb 11 2020)
                data_convertida := TO_DATE(data_texto, 'Mon DD YYYY');
                RETURN data_convertida;
            EXCEPTION WHEN OTHERS THEN
                BEGIN
                    -- Tenta DD-Mon-YYYY (ex: 23-Feb-2020)
                    data_convertida := TO_DATE(data_texto, 'DD-Mon-YYYY');
                    RETURN data_convertida;
                EXCEPTION WHEN OTHERS THEN
                    BEGIN
                        -- Tenta YYYY-MM-DD
                        data_convertida := TO_DATE(data_texto, 'YYYY-MM-DD');
                        RETURN data_convertida;
                    EXCEPTION WHEN OTHERS THEN
                        RETURN NULL;
                    END;
                END;
            END;
        END;
    END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cv(texto TEXT)
RETURNS DECIMAL AS $$
BEGIN
    IF texto IS NULL OR TRIM(texto) = '' THEN
        RETURN NULL;
    END IF;
    RETURN REPLACE(TRIM(texto), ',', '.')::DECIMAL;
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
$$ LANGUAGE plpgsql;

---------------

--- INSERT RETURNS ---
INSERT INTO dim_returns (Order_ID, Returned)
SELECT DISTINCT
    Order_ID,
    CASE 
        WHEN UPPER(TRIM(Returned)) IN ('YES', 'Y', 'RETURNED', '" YES "') THEN 'Yes'
        ELSE NULL
    END AS Returned
FROM stage_returns
WHERE Order_ID IS NOT NULL AND TRIM(Order_ID) != '';


--- INSERT PEOPLE ---
INSERT INTO dim_people (Region, Regional_Manager)
SELECT DISTINCT
    CASE 
        WHEN UPPER(TRIM(Region)) IN ('CENTRAL', 'CENTRAL REGION') THEN 'Central'
        WHEN UPPER(TRIM(Region)) = 'EAST' THEN 'East'
        WHEN UPPER(TRIM(Region)) = 'SOUTH' THEN 'South'
        WHEN UPPER(TRIM(Region)) = 'WEST' THEN 'West'
        ELSE 'Other'
    END AS Region,
    TRIM(Regional_Manager) AS Regional_Manager
FROM stage_people


--- INSERT ADDRESS ---
INSERT INTO dim_address (Country, City, State_Province, Postal_Code)
SELECT DISTINCT
    CASE 
        WHEN UPPER(TRIM(Country)) = 'UNITED STATES' THEN 'United States'
        WHEN UPPER(TRIM(Country)) = 'CANADA' THEN 'Canada'
        ELSE COALESCE(INITCAP(TRIM(Country)), 'Desconhecido')
    END AS Country,
    COALESCE(INITCAP(TRIM(City)), 'Desconhecido') AS City,
    COALESCE(INITCAP(TRIM(State_Province)), 'Desconhecido') AS State_Province,
    NULLIF(TRIM(Postal_Code), '') AS Postal_Code
FROM stage_orders
WHERE Country IS NOT NULL 
  AND TRIM(Country) != '';
    
   
--- INSERT CUSTOMER ---
INSERT INTO dim_customer(Customer_ID, Customer_Name, Segment)
SELECT DISTINCT
TRIM(customer_id) AS Customer_ID,
INITCAP(TRIM(Customer_Name)) as Customer_Name,
INITCAP(TRIM(Segment)) as Segment

FROM stage_orders
WHERE Customer_ID IS NOT NULL 
  AND Customer_Name IS NOT NULL 
  AND TRIM(Customer_Name) != '';


--- INSERT ORDER ---
INSERT INTO dim_order(Order_ID, Order_Date, Ship_Date, Ship_Mode, Region)
SELECT 
    TRIM(Order_ID) AS Order_ID,
    MIN(parse_date(TRIM(Order_Date))) AS Order_Date,
    MAX(parse_date(TRIM(Ship_Date))) AS Ship_Date,
    MIN(INITCAP(TRIM(Ship_Mode))) AS Ship_Mode,
    MIN(fn_padronizar_region(Region)) AS Region
FROM stage_orders
WHERE Order_ID IS NOT NULL 
  AND TRIM(Order_ID) != ''
GROUP BY TRIM(Order_ID);


--- INSERT PRODUCT ---
iNSERT INTO dim_product (Product_ID, Category, Sub_Category, Product_Name)
SELECT 
    TRIM(Product_ID) AS Product_ID,
    MIN(COALESCE(NULLIF(TRIM(Category), ''), 'Desconhecido')) AS Category,
    MIN(COALESCE(NULLIF(TRIM(Sub_Category), ''), 'Desconhecido')) AS Sub_Category,
    STRING_AGG(DISTINCT COALESCE(NULLIF(TRIM(Product_Name), ''), 'Produto sem nome'), ' | ') AS Product_Name
FROM stage_orders
WHERE Product_ID IS NOT NULL 
  AND TRIM(Product_ID) != ''
GROUP BY TRIM(Product_ID);


--- INSERT FACT SALES ---
INSERT INTO fact_Sales (
    Row_ID,
    Order_ID,
    Customer_ID,
    Product_ID,
    Address_ID,
    Sales,
    Quantity,
    Discount,
    Profit
)
SELECT DISTINCT
    s.Row_ID::INT,
    s.Order_ID,
    s.Customer_ID,
    s.Product_ID,
    a.Address_ID,
    ROUND(cv(s.Sales), 2) AS Sales,
    s.Quantity::INT,
    ROUND(cv(s.Discount), 4) AS Discount,
    ROUND(cv(s.Profit), 2) AS Profit
FROM stage_orders s
LEFT JOIN dim_Address a 
    ON a.Country = CASE 
        WHEN UPPER(TRIM(s.Country)) = 'UNITED STATES' THEN 'United States'
        WHEN UPPER(TRIM(s.Country)) = 'CANADA' THEN 'Canada'
        ELSE COALESCE(INITCAP(TRIM(s.Country)), 'Desconhecido')
    END
    AND a.City = COALESCE(INITCAP(TRIM(s.City)), 'Desconhecido')
    AND a.State_Province = COALESCE(INITCAP(TRIM(s.State_Province)), 'Desconhecido')
    AND COALESCE(a.Postal_Code, '') = COALESCE(NULLIF(TRIM(s.Postal_Code), ''), '')
WHERE s.Row_ID IS NOT NULL 
  AND TRIM(s.Row_ID) != ''
order by row_id asc;
