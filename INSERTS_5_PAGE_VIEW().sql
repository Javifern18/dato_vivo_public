create or replace procedure INSERTS_5_PAGE_VIEW()
returns varchar
EXECUTE AS CALLER
as
BEGIN
-- VE UN SOLO PRODUCTO EN LA SESION (1 PAGE VIEW)   [SE INSERTA 5 VECES]
begin
  for i in 1 to 5 do

insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.EVENTS
select
    UUID_STRING() as event_id,
    concat('https://greenary.com/product/',UUID_STRING()) as page_url,
    'page_view' as event_type,
    (select user_id from users sample row (1 rows)) as user_id,
    (select product_id from products sample row (1 rows)) as product_id,
    UUID_STRING() as session_id,
    DATEADD(day,-1,current_timestamp()) as created_at,
    '' as order_id,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced;    

  end for;
end;
END;
