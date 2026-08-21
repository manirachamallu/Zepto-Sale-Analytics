SELECT * FROM `bs-sql-502218.mani.Zepto_Orders` limit 10;
SELECT * FROM `bs-sql-502218.mani.Zepto_Customers` limit 10;
SELECT * FROM `bs-sql-502218.mani.Zepto_Inventory` limit 10;
SELECT * FROM `bs-sql-502218.mani.Zepto_Products` limit 10;
---------- Data Validation - Orders ----------
-- 1. Row count
SELECT COUNT(*) AS total_rows
FROM bs-sql-502218.mani.Zepto_Orders;

-- 2. Check columns and data types
SELECT
  column_name,
  data_type
FROM `bs-sql-502218.mani.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'Zepto_Orders'
ORDER BY ordinal_position;

-- 3. Duplicate Order IDs
SELECT
  OrderID,
  COUNT(*) AS occurrences
FROM bs-sql-502218.mani.Zepto_Orders
GROUP BY OrderID
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- 4. Order status distribution
SELECT
  OrderStatus,
  COUNT(*) AS orders
FROM bs-sql-502218.mani.Zepto_Orders
GROUP BY OrderStatus
ORDER BY orders DESC;


---------- Data Validation - Customers ----------
-- 1. Row Count
SELECT COUNT(*) AS total_rows
FROM bs-sql-502218.mani.Zepto_Customers;

-- 2. Column names + data types
SELECT
  column_name,
  data_type
FROM bs-sql-502218.mani.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'Zepto_Customers'
ORDER BY ordinal_position;

-- 3. Duplicate Customer IDs
SELECT
  CustomerID,
  COUNT(*) AS occurrences
FROM bs-sql-502218.mani.Zepto_Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- 4. Customer distribution by city
SELECT
  City,
  COUNT(*) AS customers
FROM bs-sql-502218.mani.Zepto_Customers
GROUP BY City
ORDER BY customers DESC;

---------- Data Validation - Products ----------
-- 1. Row Count
SELECT COUNT(*) AS total_rows
FROM bs-sql-502218.mani.Zepto_Products;

-- 2. Validating Columns and Data Types
SELECT
  column_name,
  data_type
FROM bs-sql-502218.mani.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'Zepto_Products'
ORDER BY ordinal_position;

-- 3.  Duplicate Product IDs
SELECT
  ProductID,
  COUNT(*) AS occurrences
FROM bs-sql-502218.mani.Zepto_Products
GROUP BY ProductID
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;

-- 4.Check product data
Select * FROM bs-sql-502218.mani.Zepto_Products

---------- Data Validation - Inventory ----------
-- 1. Row Count
SELECT COUNT(*) AS total_rows
FROM bs-sql-502218.mani.Zepto_Inventory;

-- 2. Validating Columns and Data Types
SELECT
    column_name,
    data_type
FROM bs-sql-502218.mani.INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'Zepto_Inventory'
ORDER BY ordinal_position;

-- 3.Check Inventory data
SELECT *
FROM bs-sql-502218.mani.Zepto_Inventory;

--------------------------------------------------------------------------------
------------- Data Modeling -------------

-- Does every customer mentioned in Orders actually exist in Customers?
SELECT
    COUNT(*) AS total_orders,
    COUNTIF(c.CustomerID IS NULL) AS unmatched_customers
FROM bs-sql-502218.mani.Zepto_Orders o
LEFT JOIN bs-sql-502218.mani.Zepto_Customers c
    ON o.CustomerID = c.CustomerID;

-- Does every product sold in Orders exist in the Products table?
SELECT
    COUNT(*) AS total_orders,
    COUNTIF(p.ProductID IS NULL) AS unmatched_products
FROM bs-sql-502218.mani.Zepto_Orders o
LEFT JOIN bs-sql-502218.mani.Zepto_Products p
    ON o.ProductID = p.ProductID;

-- Does every product have an inventory record?
SELECT
    COUNT(*) AS total_products,
    COUNTIF(i.ProductID IS NULL) AS products_without_inventory
FROM bs-sql-502218.mani.Zepto_Products p
LEFT JOIN bs-sql-502218.mani.Zepto_Inventory i
    ON p.ProductID = i.ProductID;

-- After joining Products, does one order become multiple rows?
SELECT
    o.OrderID,
    COUNT(*) AS rows_after_join
FROM bs-sql-502218.mani.Zepto_Orders o
LEFT JOIN bs-sql-502218.mani.Zepto_Products p
    ON o.ProductID = p.ProductID
GROUP BY o.OrderID
HAVING COUNT(*) > 1
ORDER BY rows_after_join DESC;

-- Final Check
SELECT
    COUNT(*) AS order_rows,
    COUNT(DISTINCT o.OrderID) AS unique_orders,
    COUNT(DISTINCT o.CustomerID) AS customers,
    COUNT(DISTINCT o.ProductID) AS products
FROM bs-sql-502218.mani.Zepto_Orders o
LEFT JOIN bs-sql-502218.mani.Zepto_Customers c
    ON o.CustomerID = c.CustomerID
LEFT JOIN bs-sql-502218.mani.Zepto_Products p
    ON o.ProductID = p.ProductID;

--------------------------------------------------------------------------------
------------------------ Data Quality ------------------------
-- 1. Missing values in Orders
SELECT
    COUNTIF(OrderID IS NULL) AS missing_order_id,
    COUNTIF(CustomerID IS NULL) AS missing_customer_id,
    COUNTIF(ProductID IS NULL) AS missing_product_id,
    COUNTIF(OrderDate IS NULL) AS missing_order_date,
    COUNTIF(Quantity IS NULL) AS missing_quantity,
    COUNTIF(UnitPrice IS NULL) AS missing_unit_price,
    COUNTIF(NetSales IS NULL) AS missing_net_sales,
    COUNTIF(OrderStatus IS NULL) AS missing_order_status,
    COUNTIF(DeliveryMinutes IS NULL) AS missing_delivery_minutes
FROM bs-sql-502218.mani.Zepto_Orders;

-- 2. checking invalid quantity
SELECT
    COUNTIF(Quantity <= 0) AS invalid_quantity,
    MIN(Quantity) AS minimum_quantity,
    MAX(Quantity) AS maximum_quantity,
    AVG(Quantity) AS average_quantity
FROM bs-sql-502218.mani.Zepto_Orders;

-- 3. Price and sales validation
SELECT
    COUNTIF(UnitPrice <= 0) AS invalid_unit_price,
    COUNTIF(NetSales < 0) AS negative_sales,
    COUNTIF(NetSales = 0) AS zero_sales,
    MIN(UnitPrice) AS minimum_unit_price,
    MAX(UnitPrice) AS maximum_unit_price,
    MIN(NetSales) AS minimum_net_sales,
    MAX(NetSales) AS maximum_net_sales

FROM `bs-sql-502218.mani.Zepto_Orders`;
-- 4. Calculation inconsistencies
-- if quantity= 5, unitprice= ₹100, Discount= 10% then net sales is = 5x100x(1-10/100)
-- ABS- Absolute Value (if the actual netsale is 499.99, expected netsale is 450, then 0.01 is difference )
SELECT
    COUNT(*) AS total_orders,
    COUNTIF(
        ABS(
            NetSales -
            (Quantity * UnitPrice * (1 - DiscountPct / 100))
        ) > 0.01
    ) AS mismatched_sales
FROM bs-sql-502218.mani.Zepto_Orders;

-- 5. Validate NetSales calculation
SELECT
    COUNT(*) AS total_orders,
    COUNTIF(
        ABS(
            NetSales -
            (Quantity * UnitPrice * (1 - DiscountPct / 100))
        ) > 0.01
    ) AS mismatched_sales
FROM bs-sql-502218.mani.Zepto_Orders;

-- 6. Delivery time validation
SELECT
    COUNT(*) AS total_orders,
    COUNTIF(DeliveryMinutes < 0) AS negative_delivery_time,
    COUNTIF(DeliveryMinutes = 0) AS zero_delivery_time,
    MIN(DeliveryMinutes) AS minimum_delivery_minutes,
    MAX(DeliveryMinutes) AS maximum_delivery_minutes,
    ROUND(AVG(DeliveryMinutes), 2) AS average_delivery_minutes
FROM bs-sql-502218.mani.Zepto_Orders;

-- 7. Delivery time vs Order Status
SELECT
    OrderStatus,
    COUNT(*) AS total_orders,
    COUNTIF(DeliveryMinutes IS NULL) AS missing_delivery_time,
    MIN(DeliveryMinutes) AS min_delivery_minutes,
    MAX(DeliveryMinutes) AS max_delivery_minutes,
    ROUND(AVG(DeliveryMinutes), 2) AS avg_delivery_minutes
FROM bs-sql-502218.mani.Zepto_Orders
GROUP BY OrderStatus
ORDER BY total_orders DESC;


------------------------------------------------------------------
-- 1. Customer Field Validation
SELECT
    COUNT(*) AS total_customers,
    COUNTIF(CustomerID IS NULL) AS missing_customer_id,
    COUNTIF(City IS NULL) AS missing_city,
    COUNTIF(LoyaltyTier IS NULL) AS missing_loyalty_tier
FROM bs-sql-502218.mani.Zepto_Customers;

SELECT
    LoyaltyTier,
    COUNT(*) AS customers
FROM bs-sql-502218.mani.Zepto_Customers
GROUP BY LoyaltyTier
ORDER BY customers DESC;


------------------------------------------------------------------
----------- Product Field Validation -------------
-- 1. Checking Missing Values
SELECT
    COUNT(*) AS total_products,
    COUNTIF(ProductID IS NULL) AS missing_product_id,
    COUNTIF(Product IS NULL) AS missing_product,
    COUNTIF(Category IS NULL) AS missing_category,
    COUNTIF(UnitPrice IS NULL) AS missing_unit_price,
    COUNTIF(MarginPct IS NULL) AS missing_margin
 FROM bs-sql-502218.mani.Zepto_Products;

-- 2. Checking Invalid Prices
SELECT
    COUNTIF(UnitPrice <= 0) AS invalid_unit_price,
    MIN(UnitPrice) AS minimum_unit_price,
    MAX(UnitPrice) AS maximum_unit_price,
    ROUND(AVG(UnitPrice), 2) AS average_unit_price
FROM bs-sql-502218.mani.Zepto_Products;

-- 3. Checking MarginPct
SELECT
    COUNTIF(MarginPct < 0) AS negative_margin,
    COUNTIF(MarginPct > 100) AS margin_over_100,
    MIN(MarginPct) AS minimum_margin,
    MAX(MarginPct) AS maximum_margin,
    ROUND(AVG(MarginPct), 2) AS average_margin
FROM bs-sql-502218.mani.Zepto_Products;


------------------------------------------------------------------
----------- Inventory Field Validation -------------
-- 1. Checking Missing Values
SELECT
    COUNT(*) AS total_inventory_records,
    COUNTIF(ProductID IS NULL) AS missing_product_id,
    COUNTIF(Product IS NULL) AS missing_product,
    COUNTIF(Warehouse IS NULL) AS missing_warehouse,
    COUNTIF(CurrentStock IS NULL) AS missing_current_stock,
    COUNTIF(ReorderLevel IS NULL) AS missing_reorder_level,
    COUNTIF(Capacity IS NULL) AS missing_capacity
FROM bs-sql-502218.mani.Zepto_Inventory;

-- 2. Stock vs Reorder Level vs Capacity
SELECT
    ProductID,
    Product,
    Warehouse,
    CurrentStock,
    ReorderLevel,
    Capacity,
    CASE
        WHEN CurrentStock < ReorderLevel THEN 'Below Reorder Level'
        WHEN CurrentStock > Capacity THEN 'Above Capacity'
        ELSE 'Normal'
    END AS InventoryStatus
select * FROM bs-sql-502218.mani.Zepto_Inventory
ORDER BY CurrentStock DESC;

-- 3. Inventory risk KPIs
SELECT
    COUNT(*) AS total_inventory_records,

    COUNTIF(CurrentStock < ReorderLevel) AS below_reorder_level,

    COUNTIF(CurrentStock > Capacity) AS above_capacity,

    COUNTIF(
        CurrentStock >= ReorderLevel
        AND CurrentStock <= Capacity
    ) AS normal_stock,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(CurrentStock < ReorderLevel),
            COUNT(*)
        ) * 100,
        2
    ) AS stockout_risk_pct,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(CurrentStock > Capacity),
            COUNT(*)
        ) * 100,
        2
    ) AS above_capacity_pct

FROM bs-sql-502218.mani.Zepto_Inventory;


------------------------------------------------------------------------------------------------------------------------------------
---------- Business KPI's-----------
------------------------------------------------------------------------------------------------------------------------------------

-- 1. How is Zepto Performing?
-- We Establish ->Total Revenus, ->Total Orders, ->Delicered Orders, ->Unit Sold, ->AOV, ->Return Rate, ->Cancellation Rate, ->Average Delivery Time
SELECT
    COUNT(DISTINCT OrderID) AS Total_Orders,

    COUNT(DISTINCT CASE
        WHEN OrderStatus = "Delivered" THEN OrderID  
    END) AS Delivered_orders,

    SUM(CASE 
        WHEN OrderStatus = "Delivered" THEN Quantity
        ELSE 0
    END) AS Units_Sold,

    ROUND(
      SUM(CASE
          WHEN OrderStatus = "Delivered"
          THEN NetSales
          ELSE 0 
      END),
      2 
    )AS Total_Revenue,

    ROUND(
      SAFE_DIVIDE(
       SUM(CASE
          WHEN OrderStatus = "Delivered"
          THEN NetSales
          ELSE 0
      END),
      COUNT(DISTINCT CASE
            WHEN OrderStatus = "Delivered"
            THEN OrderID
      END) 
         ),
        2
    )AS Average_Order_Value,

    ROUND(
      AVG(CASE
          WHEN OrderStatus = "Delivered"
          THEN DeliveryMinutes
      END),
      2
    )AS Avg_delivery_minutes,

    ROUND(
      SAFE_DIVIDE(
      COUNT(DISTINCT CASE
            WHEN OrderStatus = "Returned"
            THEN OrderID
      END),
      COUNT(DISTINCT OrderID)
      ) * 100,
      2
    )AS Return_RatePct,

    ROUND(
      SAFE_DIVIDE(
      COUNT(DISTINCT CASE
            WHEN OrderStatus = "Cancelled"
            THEN OrderID
      END),
      COUNT(DISTINCT OrderID)
      ) * 100,
      2
    )AS Cancelled_RatePct
FROM bs-sql-502218.mani.Zepto_Orders;


-- 2. Which cities are driving revenue, and which cities are causing operational problems?
-- We Establish ->Total/Delivered Orders, ->Revenue, ->AOV, ->Avg DeliveryTime, ->Return Rate, ->Cancellation Rate
SELECT
    City,

    COUNT(DISTINCT OrderID) AS Total_orders,

    COUNT(DISTINCT CASE
        WHEN OrderStatus = "Delivered"
        THEN OrderID
    END) AS Delivered_Orders,

    ROUND(
      SUM(CASE
        WHEN OrderStatus = "Delivered"
        THEN NetSales
        ELSE 0 
      END),
      2
    )AS Total_Revenue,

    ROUND(
      SAFE_DIVIDE(
        SUM(CASE 
          WHEN OrderStatus = "Delivered"
          THEN NetSales 
          ELSE 0
        END),
        COUNT(DISTINCT CASE
            WHEN OrderStatus = "Delivered"
            THEN OrderID
        END)
      ),
      2
    )AS Avg_OrderValue,

    ROUND(
      AVG(CASE 
        WHEN OrderStatus = "Delivered"
        THEN DeliveryMinutes
      END),
      2
    )AS Avg_Delivery_Minutes,

    ROUND(
      SAFE_DIVIDE(
        COUNT(DISTINCT CASE
          WHEN OrderStatus = "Returned"
          THEN OrderID
        END),
        COUNT(DISTINCT OrderID)
      ) * 100,
      2
    )AS Return_RatePct,

    ROUND(
      SAFE_DIVIDE(
        COUNT(DISTINCT CASE
          WHEN OrderStatus = "Cancelled"
          THEN OrderID
        END),
        COUNT(DISTINCT OrderID)
      ) * 100,
      2
    )AS Cancelled_RatePct

FROM bs-sql-502218.mani.Zepto_Orders
GROUP BY City
ORDER BY Total_Revenue DESC;

    
    
-- 3. Which product categories generate the most revenue, units, and estimated gross profit, and which categories have high return rates?

SELECT
    o.Category,

    COUNT(DISTINCT o.OrderID) AS Total_Orders,

    SUM(
        CASE
            WHEN o.OrderStatus = 'Delivered'
            THEN o.Quantity
            ELSE 0
        END
    ) AS Units_Sold,

    ROUND(
        SUM(
            CASE
                WHEN o.OrderStatus = 'Delivered'
                THEN o.NetSales
                ELSE 0
            END
        ),
        2
    ) AS Total_Revenue,

    ROUND(
        SUM(
            CASE
                WHEN o.OrderStatus = 'Delivered'
                THEN o.NetSales * (p.MarginPct / 100)
                ELSE 0
            END
        ),
        2
    ) AS Estimated_Gross_Profit,

    ROUND(
        SAFE_DIVIDE(
            SUM(
                CASE
                    WHEN o.OrderStatus = 'Delivered'
                    THEN o.NetSales * (p.MarginPct / 100)
                    ELSE 0
                END
            ),
            SUM(
                CASE
                    WHEN o.OrderStatus = 'Delivered'
                    THEN o.NetSales
                    ELSE 0
                END
            )
        ) * 100,
        2
    ) AS Estimated_Gross_Margin_Pct,

    ROUND(
        SAFE_DIVIDE(
            COUNT(DISTINCT CASE
                WHEN o.OrderStatus = 'Returned'
                THEN o.OrderID
            END),
            COUNT(DISTINCT o.OrderID)
        ) * 100,
        2
    ) AS Return_Rate_Pct

FROM bs-sql-502218.mani.Zepto_Orders o

LEFT JOIN bs-sql-502218.mani.Zepto_Products p
    ON o.ProductID = p.ProductID

GROUP BY o.Category

ORDER BY Total_Revenue DESC;
      
-- PRODUCT PERFORMANCE 
SELECT
    o.ProductID,
    o.Product,

    COUNT(DISTINCT o.OrderID) AS Total_Orders,

    SUM(
        CASE
            WHEN o.OrderStatus = 'Delivered'
            THEN o.Quantity
            ELSE 0
        END
    ) AS Units_Sold,

    ROUND(
        SUM(
            CASE
                WHEN o.OrderStatus = 'Delivered'
                THEN o.NetSales
                ELSE 0
            END
        ),
        2
    ) AS Total_Revenue,

    ROUND(
        SUM(
            CASE
                WHEN o.OrderStatus = 'Delivered'
                THEN o.NetSales * (p.MarginPct / 100)
                ELSE 0
            END
        ),
        2
    ) AS Estimated_Gross_Profit,

    ROUND(AVG(p.MarginPct), 2) AS Margin_Pct,

    ROUND(
        SAFE_DIVIDE(
            SUM(
                CASE
                    WHEN o.OrderStatus = 'Delivered'
                    THEN o.NetSales * (p.MarginPct / 100)
                    ELSE 0
                END
            ),
            SUM(
                CASE
                    WHEN o.OrderStatus = 'Delivered'
                    THEN o.NetSales
                    ELSE 0
                END
            )
        ) * 100,
        2
    ) AS Estimated_Gross_Margin_Pct

FROM bs-sql-502218.mani.Zepto_Orders o

LEFT JOIN bs-sql-502218.mani.Zepto_Products p
    ON o.ProductID = p.ProductID

GROUP BY
    o.ProductID,
    o.Product

ORDER BY Estimated_Gross_Profit DESC;


--------------------------------------------------------------------------------------------------------------------------

-- Customer/Loyalty Performance

SELECT
    c.LoyaltyTier,

    COUNT(DISTINCT c.CustomerID) AS Total_Customers,

    COUNT(DISTINCT o.OrderID) AS Total_Orders,

    ROUND(
        SUM(
            CASE
                WHEN o.OrderStatus = 'Delivered'
                THEN o.NetSales
                ELSE 0
            END
        ),
        2
    ) AS Total_Revenue,

    ROUND(
        SAFE_DIVIDE(
            SUM(
                CASE
                    WHEN o.OrderStatus = 'Delivered'
                    THEN o.NetSales
                    ELSE 0
                END
            ),
            COUNT(DISTINCT CASE
                WHEN o.OrderStatus = 'Delivered'
                THEN o.OrderID
            END)
        ),
        2
    ) AS AOV,

    ROUND(
        SAFE_DIVIDE(
            COUNT(DISTINCT o.OrderID),
            COUNT(DISTINCT c.CustomerID)
        ),
        2
    ) AS Orders_Per_Customer

FROM bs-sql-502218.mani.Zepto_Customers c

LEFT JOIN bs-sql-502218.mani.Zepto_Orders o
    ON c.CustomerID = o.CustomerID

GROUP BY c.LoyaltyTier

ORDER BY Total_Revenue DESC;

---------------------------------------------------------------------------
-- 6.Monthly Sales Trend
SELECT
    DATE_TRUNC(OrderDate, MONTH) AS Order_Month,

    COUNT(DISTINCT OrderID) AS Total_Orders,

    COUNT(DISTINCT CASE
        WHEN OrderStatus = 'Delivered'
        THEN OrderID
    END) AS Delivered_Orders,

    ROUND(
        SUM(CASE
            WHEN OrderStatus = 'Delivered'
            THEN NetSales
            ELSE 0
        END),
        2
    ) AS Total_Revenue,

    SUM(CASE
        WHEN OrderStatus = 'Delivered'
        THEN Quantity
        ELSE 0
    END) AS Units_Sold,

    ROUND(
        AVG(CASE
            WHEN OrderStatus = 'Delivered'
            THEN DeliveryMinutes
        END),
        2
    ) AS Avg_Delivery_Minutes

FROM bs-sql-502218.mani.Zepto_Orders

GROUP BY Order_Month

ORDER BY Order_Month;

------------------------------------------------
--  7 — Delivery SLA Performance
SELECT
    COUNT(DISTINCT OrderID) AS Total_Delivered_Orders,

    COUNTIF(DeliveryMinutes <= 30) AS On_Time_Orders,

    COUNTIF(DeliveryMinutes > 30) AS Late_Orders,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(DeliveryMinutes <= 30),
            COUNT(*)
        ) * 100,
        2
    ) AS On_Time_Rate_Pct,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(DeliveryMinutes > 30),
            COUNT(*)
        ) * 100,
        2
    ) AS Late_Rate_Pct,

    ROUND(
        AVG(DeliveryMinutes),
        2
    ) AS Avg_Delivery_Minutes,

    ROUND(
        MAX(DeliveryMinutes),
        2
    ) AS Max_Delivery_Minutes

FROM bs-sql-502218.mani.Zepto_Orders

WHERE OrderStatus = 'Delivered';

-----------------------------------------------
-- 8 — On-Time Delivery by City
SELECT
    City,

    COUNT(DISTINCT OrderID) AS Delivered_Orders,

    COUNTIF(DeliveryMinutes <= 30) AS On_Time_Orders,

    COUNTIF(DeliveryMinutes > 30) AS Late_Orders,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(DeliveryMinutes <= 30),
            COUNT(*)
        ) * 100,
        2
    ) AS On_Time_Rate_Pct,

    ROUND(
        AVG(DeliveryMinutes),
        2
    ) AS Avg_Delivery_Minutes,

    ROUND(
        MAX(DeliveryMinutes),
        2
    ) AS Max_Delivery_Minutes

FROM bs-sql-502218.mani.Zepto_Orders

WHERE OrderStatus = 'Delivered'

GROUP BY City

ORDER BY On_Time_Rate_Pct ASC;


---------------------------------------
-- 9.Are discounts actually helping?
SELECT
    DiscountPct,

    COUNT(DISTINCT OrderID) AS Total_Orders,

    COUNT(DISTINCT CASE
        WHEN OrderStatus = 'Delivered'
        THEN OrderID
    END) AS Delivered_Orders,

    ROUND(
        SUM(CASE
            WHEN OrderStatus = 'Delivered'
            THEN NetSales
            ELSE 0
        END),
        2
    ) AS Total_Revenue,

    ROUND(
        SAFE_DIVIDE(
            SUM(CASE
                WHEN OrderStatus = 'Delivered'
                THEN NetSales
                ELSE 0
            END),
            COUNT(DISTINCT CASE
                WHEN OrderStatus = 'Delivered'
                THEN OrderID
            END)
        ),
        2
    ) AS AOV,

    ROUND(
        SUM(CASE
            WHEN OrderStatus = 'Delivered'
            THEN NetSales * (p.MarginPct / 100)
            ELSE 0
        END),
        2
    ) AS Estimated_Gross_Profit,

    ROUND(
        SAFE_DIVIDE(
            SUM(CASE
                WHEN OrderStatus = 'Delivered'
                THEN NetSales * (p.MarginPct / 100)
                ELSE 0
            END),
            SUM(CASE
                WHEN OrderStatus = 'Delivered'
                THEN NetSales
                ELSE 0
            END)
        ) * 100,
        2
    ) AS Estimated_Gross_Margin_Pct

FROM bs-sql-502218.mani.Zepto_Orders o

LEFT JOIN bs-sql-502218.mani.Zepto_Products p
    ON o.ProductID = p.ProductID

GROUP BY DiscountPct

ORDER BY DiscountPct;


---------------------------
-- 9.Are we holding the right amount of stock for the products customers are actually buying?
WITH ProductSales AS (
    SELECT
        ProductID,
        SUM(
            CASE
                WHEN OrderStatus = 'Delivered'
                THEN Quantity
                ELSE 0
            END
        ) AS Units_Sold,

        ROUND(
            SUM(
                CASE
                    WHEN OrderStatus = 'Delivered'
                    THEN NetSales
                    ELSE 0
                END
            ),
            2
        ) AS Total_Revenue

    FROM `bs-sql-502218.mani.Zepto_Orders`

    GROUP BY ProductID
)

SELECT
    i.ProductID,
    i.Product,
    i.Warehouse,
    i.CurrentStock,
    i.ReorderLevel,
    i.Capacity,

    COALESCE(s.Units_Sold, 0) AS Units_Sold,
    COALESCE(s.Total_Revenue, 0) AS Total_Revenue,

    CASE
        WHEN i.CurrentStock < i.ReorderLevel
            THEN 'Stock Risk'

        WHEN i.CurrentStock > i.Capacity
            THEN 'Over Capacity'

        ELSE 'Normal'
    END AS Inventory_Status

FROM bs-sql-502218.mani.Zepto_Inventory i

LEFT JOIN ProductSales s
    ON i.ProductID = s.ProductID

ORDER BY
    Units_Sold DESC;


---------------------------
-- 11. How dependent is Zepto’s revenue on repeat customers?
WITH CustomerOrders AS (

    SELECT
        CustomerID,

        COUNT(DISTINCT OrderID) AS Total_Orders,

        COUNT(DISTINCT CASE
            WHEN OrderStatus = 'Delivered'
            THEN OrderID
        END) AS Delivered_Orders,

        ROUND(
            SUM(CASE
                WHEN OrderStatus = 'Delivered'
                THEN NetSales
                ELSE 0
            END),
            2
        ) AS Total_Revenue

    FROM bs-sql-502218.mani.Zepto_Orders

    GROUP BY CustomerID
),

CustomerSegments AS (

    SELECT
        CustomerID,
        Total_Orders,
        Delivered_Orders,
        Total_Revenue,

        CASE
            WHEN Total_Orders = 1
                THEN 'One-time'

            WHEN Total_Orders BETWEEN 2 AND 3
                THEN 'Occasional'

            WHEN Total_Orders BETWEEN 4 AND 6
                THEN 'Regular'

            ELSE 'Loyal'
        END AS Customer_Segment

    FROM CustomerOrders
)

SELECT
    Customer_Segment,

    COUNT(*) AS Customers,

    SUM(Total_Orders) AS Total_Orders,

    SUM(Delivered_Orders) AS Delivered_Orders,

    ROUND(SUM(Total_Revenue), 2) AS Total_Revenue,

    ROUND(
        SAFE_DIVIDE(
            SUM(Total_Revenue),
            COUNT(*)
        ),
        2
    ) AS Revenue_Per_Customer,

    ROUND(
        SAFE_DIVIDE(
            SUM(Total_Orders),
            COUNT(*)
        ),
        2
    ) AS Orders_Per_Customer

FROM CustomerSegments

GROUP BY Customer_Segment

ORDER BY Total_Revenue DESC;


----------------------------------
-- 12. Final Opportunity Analysis
WITH ProductPerformance AS (

    SELECT
        o.ProductID,
        o.Product,

        SUM(
            CASE
                WHEN o.OrderStatus = 'Delivered'
                THEN o.Quantity
                ELSE 0
            END
        ) AS Units_Sold,

        SUM(
            CASE
                WHEN o.OrderStatus = 'Delivered'
                THEN o.NetSales
                ELSE 0
            END
        ) AS Revenue,

        SUM(
            CASE
                WHEN o.OrderStatus = 'Delivered'
                THEN o.NetSales * (p.MarginPct / 100)
                ELSE 0
            END
        ) AS Estimated_Gross_Profit,

        AVG(p.MarginPct) AS Margin_Pct,

        SAFE_DIVIDE(
            COUNT(DISTINCT CASE
                WHEN o.OrderStatus = 'Returned'
                THEN o.OrderID
            END),
            COUNT(DISTINCT o.OrderID)
        ) * 100 AS Return_Rate_Pct

    FROM bs-sql-502218.mani.Zepto_Orders o

    LEFT JOIN bs-sql-502218.mani.Zepto_Products p
        ON o.ProductID = p.ProductID

    GROUP BY
        o.ProductID,
        o.Product
),

RankedProducts AS (

    SELECT
        *,
        
        PERCENT_RANK() OVER (
            ORDER BY Revenue
        ) AS Revenue_Rank,

        PERCENT_RANK() OVER (
            ORDER BY Estimated_Gross_Profit
        ) AS Profit_Rank

    FROM ProductPerformance
)

SELECT
    ProductID,
    Product,

    Units_Sold,

    ROUND(Revenue, 2) AS Revenue,

    ROUND(Estimated_Gross_Profit, 2) AS Estimated_Gross_Profit,

    ROUND(Margin_Pct * 100, 2) AS Margin_Pct,

    ROUND(Return_Rate_Pct, 2) AS Return_Rate_Pct,

    CASE
        WHEN Revenue_Rank >= 0.75
             AND Profit_Rank >= 0.75
            THEN 'Core Product'

        WHEN Revenue_Rank >= 0.75
             AND Profit_Rank < 0.75
            THEN 'Revenue Driver - Low Profit'

        WHEN Revenue_Rank < 0.75
             AND Profit_Rank >= 0.75
            THEN 'High Profit Growth Opportunity'

        ELSE 'Low Priority'
    END AS Business_Action

FROM RankedProducts

ORDER BY Estimated_Gross_Profit DESC;

