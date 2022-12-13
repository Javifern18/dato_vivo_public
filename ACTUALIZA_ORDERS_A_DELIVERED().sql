create or replace procedure ACTUALIZA_ORDERS_A_DELIVERED()
returns varchar
EXECUTE AS CALLER
as
begin
update DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ORDERS
    set
        delivered_at = (select DATEADD(day,normal(5,2,random()),CURRENT_TIMESTAMP())),
        status = 'delivered',
        _fivetran_synced = current_timestamp()
    where delivered_at is null;
END;
