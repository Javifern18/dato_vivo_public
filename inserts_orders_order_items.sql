BEGIN
begin
  for i in 1 to 30 do

set order_id = (select UUID_STRING());
set shipping_service = (select shipping_service from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDERS sample row (1 rows));
set shipping_cost = (select round(normal((select avg(shipping_cost) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDERS),3,random())));
set address_id = (select address_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.addresses sample row (1 rows));
set created_at = (select DATEADD(day,-4,current_timestamp()));
set promo_id = '';
set estimated_delivery_at = (select DATEADD(day,-2,current_timestamp()));
set order_cost = (select round(normal((select avg(order_cost) from  DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.orders),3,random())));
set user_id = (select user_id from  DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.users sample row (1 rows));
set order_total = (select round(normal((select avg(order_total) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.orders),3,random())));
set delivered_at = (select current_timestamp());
set tracking_id = (select UUID_STRING());
set status = 'delivered';
set _fivetran_deleted = null;
set _fivetran_synced = current_timestamp();

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDERS
select 
    $order_id as order_id,
    $shipping_service as shipping_service, 
    $shipping_cost as shipping_cost,
    $address_id as address_id, 
    $created_at as created_at, 
    $promo_id as promo_id, 
    $estimated_delivery_at as estimated_delivery_at, 
    $order_cost as order_cost, 
    $user_id as user_id, 
    $order_total as order_total,
    $delivered_at as delivered_at,
    $tracking_id as tracking_id,
    $status as status,
    $_fivetran_deleted as _fivetran_deleted,
    $_fivetran_synced as _fivetran_synced;

set product_id =  (select product_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.products sample row (1 rows));
set quantity = (select round(normal((select avg(quantity) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.order_items),0.75,random())));
set _fivetran_deleted = false;
set _fivetrna_synced = current_timestamp();

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDER_ITEMS
select
    $order_id as order_id,
    $product_id as product_id,
    $quantity as quantity,
    $_fivetran_deleted as _fivetran_deleted,
    $_fivetrna_synced as _fivetran_synced;
    
  end for;
end;  
END;  
