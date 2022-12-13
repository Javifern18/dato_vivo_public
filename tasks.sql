create or replace task EVENTS_TASK 
WAREHOUSE = dev_transform_wh_curso
schedule = 'USING CRON 0 0-23 * * * UTC'
as 
BEGIN
------ INSERT EN EVENTS, ORDERS,ORDER_ITEMS
-- INSERTA 5 EVENTOS DE PAGE VIEW
BEGIN
call INSERTS_5_PAGE_VIEW();
END;
-- INSERTA 2 EVENTOS DE 1 PAGE VIEW Y 1 ADD TO CART
BEGIN
call INSERTS_2_1_PAGE_VIEW_1_ADD_TO_CART();
END;
-- INSERTA 1 EVENTO QUE ACABA EN COMPRA Y POR TANTO TAMBIÉN UN ORDER Y UN ORDER ITEM
BEGIN
call INSERTS_CHECKOUT_PACKAGE_SHIPPED();
END;

END;
ALTER TASK EVENTS_TASK RESUME;
ALTER TASK EVENTS_TASK suspend;
----------------------------------------------------------------------
-------------------------------- AHORA DBT BUILD----------------------
----------------------------------------------------------------------
create or replace task FINAL_TASK 
WAREHOUSE = dev_transform_wh_curso
schedule = 'USING CRON 0 0-23 * * * UTC'
as
BEGIN
-- ACTUALIZA ORDER ANTERIOR A DELIVERED
BEGIN
call ACTUALIZA_ORDERS_A_DELIVERED();
END;

-------------------------------------
-- ACTUALIZA STOCK
BEGIN
call actualiza_stock();
END;

-------------------------------------
-- ACTUALIZA PRICE
BEGIN
call actualiza_price();
END;

-------------------------------------
-- ACTUALIZA PROMOS
BEGIN
call actualiza_promos();
END;

-------------------------------------
-- INSERTS EN ADDRESSES
BEGIN
call INSERTS_ADDRESSES();
END;

------------------------------------
-- ACTUALIZA USUARIOS
BEGIN
call actualiza_users();
END;
END;
ALTER TASK FINAL_TASK RESUME;
ALTER TASK FINAL_TASK suspend;
----------------------------------------------------------------------
-------------------------------- AHORA DBT BUILD----------------------
----------------------------------------------------------------------
