create or replace procedure INSERTS_2_1_PAGE_VIEW_1_ADD_TO_CART()
returns varchar
EXECUTE AS CALLER
as
begin

for i in 1 to 2 do
let user_id varchar := (select user_id from DEV_BRONZE_DB_ALUMNO18.sql_server_dbo.users sample row (1 rows));
let session_id varchar := (select UUID_STRING());
let product_url varchar := (select UUID_STRING());
let product_id varchar := (select product_id from DEV_BRONZE_DB_ALUMNO18.sql_server_dbo.products sample row (1 rows));
let created_at date := DATEADD(day,-1,current_timestamp());

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
    
  end for;
end;
