use dev_bronze_db_alumno18.core;
-- INSERTA 1 EVENTO QUE ACABA EN COMPRA Y POR TANTO TAMBIÉN UN ORDER Y UN ORDER ITEM
BEGIN
call INSERTS_CHECKOUT_PACKAGE_SHIPPED();
END;
------------------------------------ DBT BUILD
select * from dev_gold_db_alumno18.core.fct_order_status where order_status != 'delivered';

-- ACTUALIZA ORDER ANTERIOR A DELIVERED
BEGIN
call ACTUALIZA_ORDERS_A_DELIVERED();
END;
------------------------------------ DBT BUILD
select * from dev_gold_db_alumno18.core.fct_order_status where order_status != 'delivered';

---------------------------------------------------------------------------------------------
-------------------------------UPDATE USERS--------------------------------------------------

BEGIN
call actualiza_users();
END;
------------------------------------ DBT BUILD
select * from dev_gold_db_alumno18.core.dim_users;
select * from dev_gold_db_alumno18.core.dim_users_today;

---------------------------------------------------------------------------------------------
-------------------------------UPDATE PRODUCTS PRICE Y STOCK--------------------------------------------------
BEGIN
call actualiza_stock();
END;

BEGIN
call actualiza_price();
END;
------------------------------------ DBT BUILD
select * from dev_bronze_db_alumno18.sql_server_dbo.products;

select * from dev_gold_db_alumno18.core.fct_stock;
select * from dev_gold_db_alumno18.core.dim_products;
select * from dev_gold_db_alumno18.core.dim_products_today;
