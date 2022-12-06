-- Sample a fraction of a table, with a specified probability for including a given row. 
select * from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ADDRESSES sample block (1);

-- Sample a fixed, specified number of rows. 
SELECT * from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ADDRESSES sample row (1 rows);

-- BLOCK sampling is often faster than ROW sampling. 
-- Sampling without a seed is often faster than sampling with a seed.

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

                                    -- EVENTS
                                    
select * from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS;


-- VE UN SOLO PRODUCTO EN LA SESION (1 PAGE VIEW)   [SE INSERTA 5 VECES]
begin
  for i in 1 to 5 do

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    (select user_id from users sample row (1 rows)) as user_id,
    '' as order_id,
    UUID_STRING() as session_id,
    concat('https://greenary.com/product/',UUID_STRING()) as page_url,
    DATEADD(day,-1,current_timestamp()) as created_at,
    'page_view' as event_type,
    (select product_id from products sample row (1 rows)) as product_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;    
    
  end for;
end;

-- AÑADE UN PRODUCTO AL CARRITO EN LA SESION (1 PAGE VIEW, 1 ADD TO CART)   [SE INSERTA 2 VECES]
begin
  for i in 1 to 2 do

set user_id = (select user_id from users sample row (1 rows));
set session_id = (select UUID_STRING());
set product_url = (select UUID_STRING());
set product_id = (select product_id from products sample row (1 rows));
set created_at= DATEADD(day,-1,current_timestamp());

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    $user_id as user_id,
    '' as order_id,
    $session_id as session_id,
    concat('https://greenary.com/product/',$product_url) as page_url,
    $created_at as created_at,
    'page_view' as event_type,
    $product_id as product_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;    
    
insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    $user_id as user_id,
    '' as order_id,
    $session_id as session_id,
    concat('https://greenary.com/product/',$product_url) as page_url,
    TIMEADD(min,1,$created_at) as created_at,
    'add_to_cart' as event_type,
    $product_id as product_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;  
    
  end for;
end;

-- COMPRA DE UN PRODUCTO AL CARRITO EN LA SESION (1 PAGE VIEW, 1 ADD TO CART, 1 CHECKOUT, 1 PACKAGE SHIPPED)

set user_id = (select user_id from users sample row (1 rows));
set session_id = (select UUID_STRING());
set product_url = (select UUID_STRING());
set product_id = (select product_id from products sample row (1 rows));
set created_at = DATEADD(day,-1,current_timestamp());
set order_id = (select UUID_STRING());

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    $user_id as user_id,
    '' as order_id,
    $session_id as session_id,
    concat('https://greenary.com/product/',$product_url) as page_url,
    $created_at as created_at,
    'page_view' as event_type,
    $product_id as product_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;    

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    $user_id as user_id,
    '' as order_id,
    $session_id as session_id,
    concat('https://greenary.com/product/',$product_url) as page_url,
    TIMEADD(min,1,$created_at) as created_at,
    'add_to_cart' as event_type,
    $product_id as product_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;  

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    $user_id as user_id,
    $order_id as order_id,
    $session_id as session_id,
    concat('https://greenary.com/checkout/',$product_url) as page_url,
    TIMEADD(min,2,$created_at) as created_at,
    'checkout' as event_type,
    '' as product_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    $user_id as user_id,
    $order_id as order_id,
    $session_id as session_id,
    concat('https://greenary.com/shipping/',$product_url) as page_url,
    TIMEADD(hour,2,$created_at) as created_at,
    'package_shipped' as event_type,
    '' as product_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;
    
-------------------------------------------------------
-- Insert en orders (los pedidos de la página los envío a la dirección principal del usuario)
-- Status = 'shipped'
set shipping_service = (select shipping_service from orders sample row (1 rows) where status != 'preparing');
set address_id = (select address_id from users where user_id = $user_id); -- (pedidos se envían a la dirección principal del usuario)
set promo_id = (select promo_id from promos union select '' ORDER BY random() LIMIT 1);
set shipping_cost = (select round(normal((select avg(shipping_cost) from orders),3,random())));
set order_cost = (select round(normal((select avg(order_cost) from orders),3,random())));
set estimated_delivery_at = (select DATEADD(day,normal(5,1.5,random()),$created_at));
set tracking_id = (select UUID_STRING()); 

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDERS
select 
    $order_id as order_id,
    $shipping_service as shipping_service, 
    $shipping_cost as shipping_cost,
    $address_id as address_id, 
    TIMEADD(min,2,$created_at) as created_at,     
    $promo_id as promo_id,   
    $estimated_delivery_at as estimated_delivery_at, 
    $order_cost as order_cost, 
    $user_id as user_id, 
    order_cost + shipping_cost as order_total,
    null as delivered_at,
    $tracking_id as tracking_id,
    'shipped' as status,
    null as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;

-- Insert en order_items
insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDER_ITEMS
select
    $order_id as order_id,
    $product_id as product_id,
    round(normal((select avg(quantity) from order_items),0.75,random())) as quantity,
    false as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;
    
--------------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------

-- ESTO EN OTRA TAREA POSTERIOR DESPUES DE HABER HECHO DBT BUILD
-- INSERT CON ACTUALIZACION PEDIDO EN ORDERS A STATUS DELIVERED    

set delivered_at = (select DATEADD(day,normal(5,2,random()),$created_at));

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDERS
select 
    $order_id as order_id,
    $shipping_service as shipping_service, 
    $shipping_cost as shipping_cost,
    $address_id as address_id, 
    TIMEADD(min,2,$created_at) as created_at,     
    $promo_id as promo_id,   
    $estimated_delivery_at as estimated_delivery_at, 
    $order_cost as order_cost, 
    $user_id as user_id, 
    order_cost + shipping_cost as order_total,
    $delivered_at as delivered_at,
    $tracking_id as tracking_id,
    'delivered' as status,
    null as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;

select $order_id as NK_order_id;


