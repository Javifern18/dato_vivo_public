create or replace procedure INSERTS_ADDRESSES()
returns varchar
EXECUTE AS CALLER
as
BEGIN                                    
insert into DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ADDRESSES
select
    UUID_STRING() as address_id,
    zipcode,
    country,
    randstr(12, random()) as address,
    state,
    FALSE as _fivetran_deleted,
    current_timestamp() as _fivetran_synced

from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.ADDRESSES sample block (5);
END;
