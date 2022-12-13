create or replace procedure INSERTS_CHECKOUT_PACKAGE_SHIPPED()
returns varchar
EXECUTE AS CALLER
as
begin
-- COMPRA DE UN PRODUCTO AL CARRITO EN LA SESION (1 PAGE VIEW, 1 ADD TO CART, 1 CHECKOUT, 1 PACKAGE SHIPPED)
LET user_id VARCHAR := (select user_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.users sample row (1 rows));
LET session_id VARCHAR := (select UUID_STRING());
LET product_url VARCHAR := (select UUID_STRING());
LET product_id VARCHAR := (select product_id from products sample row (1 rows));
LET created_at VARCHAR := DATEADD(day,-1,current_timestamp());
LET order_id VARCHAR := (select UUID_STRING());

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    concat('https://greenary.com/product/',:product_url) as page_url,
    'page_view' as event_type,
    :user_id as user_id,
    :product_id as product_id,
    :session_id as session_id,
    :created_at as created_at,
    '' as order_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;    

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    concat('https://greenary.com/product/',:product_url) as page_url,
    'add_to_cart' as event_type,
    :user_id as user_id,
    :product_id as product_id,
    :session_id as session_id,
    TIMEADD(min,1,:created_at) as created_at,
    '' as order_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;  

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    concat('https://greenary.com/checkout/',:product_url) as page_url,
    'checkout' as event_type,
    :user_id as user_id,
    '' as product_id,
    :session_id as session_id,
    TIMEADD(min,2,:created_at) as created_at,
    :order_id as order_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    concat('https://greenary.com/shipping/',:product_url) as page_url,
    'package_shipped' as event_type,
    :user_id as user_id,
    '' as product_id,
    :session_id as session_id,
    TIMEADD(hour,2,:created_at) as created_at,
    :order_id as order_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;  
-------------------------------------------------------
-- Insert en orders (los pedidos de la página los envío a la dirección principal del usuario)
-- Status = 'shipped'
LET shipping_service VARCHAR := (select shipping_service from orders sample row (1 rows) where status != 'preparing');
LET address_id VARCHAR := (select address_id from users where user_id = :user_id); -- (pedidos se envían a la dirección principal del usuario)
LET promo_id VARCHAR := (select promo_id from promos union select '' ORDER BY random() LIMIT 1);
LET shipping_cost NUMBER := (select round(normal((select avg(shipping_cost) from orders),3,random())));
LET order_cost NUMBER:= (select round(normal((select avg(order_cost) from orders),3,random())));
LET estimated_delivery_at TIMESTAMP_TZ := (select DATEADD(day,normal(5,1.5,random()),:created_at));
LET tracking_id VARCHAR := (select UUID_STRING()); 

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDERS
select 
    :order_id as order_id,
    :shipping_service as shipping_service, 
    :shipping_cost as shipping_cost,
    :address_id as address_id, 
    TIMEADD(min,2,:created_at) as created_at,     
    :promo_id as promo_id,   
    :estimated_delivery_at as estimated_delivery_at, 
    :order_cost as order_cost, 
    :user_id as user_id, 
    order_cost + shipping_cost as order_total,
    null as delivered_at,
    :tracking_id as tracking_id,
    'shipped' as status,
    null as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;

-- Insert en order_items
insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDER_ITEMS
select
    :order_id as order_id,
    :product_id as product_id,
    round(normal((select avg(quantity) from order_items),0.75,random())) as quantity,
    false as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;

END;
