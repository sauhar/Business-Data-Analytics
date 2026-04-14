select *
from dirty_cafe_sales_dataset


ALTER TABLE dirty_cafe_sales_dataset RENAME COLUMN "Transaction ID" TO transaction_id;
ALTER TABLE dirty_cafe_sales_dataset RENAME COLUMN "Item" TO item;
ALTER TABLE dirty_cafe_sales_dataset RENAME COLUMN "Quantity" TO quantity;
ALTER TABLE dirty_cafe_sales_dataset RENAME COLUMN "Price Per Unit" TO price_per_unit;
ALTER TABLE dirty_cafe_sales_dataset RENAME COLUMN "Total Spent" TO total_spent;
ALTER TABLE dirty_cafe_sales_dataset RENAME COLUMN "Payment Method" TO payment_method;
ALTER TABLE dirty_cafe_sales_dataset RENAME COLUMN "Location" TO location;
ALTER TABLE dirty_cafe_sales_dataset RENAME COLUMN "Transaction Date" TO transaction_date;



SELECT *
FROM dirty_cafe_sales_dataset
WHERE quantity BETWEEN '2' AND '4' limit 10;