create or replace procedure actualiza_promos()
returns varchar
EXECUTE AS CALLER
as
BEGIN

LET promo_id VARCHAR := null;

create or replace temporary table DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_promos as (
    select 
        row_number() over (order by promo_id) as row_number,
        promo_id,
        discount
    
     from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PROMOS 
);

LET num_promos NUMBER := (select max(row_number) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_promos);

  for i in 1 to :num_promos do
  
  set promo_id = (select promo_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_promos where row_number=:i);
  
  update DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PROMOS
    set
        discount = round(normal((select avg(discount) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PROMOS),1.5,random())),
        _fivetran_synced = current_timestamp()
    where promo_id = :promo_id;    

  end for;

drop table DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_promos;

END;
