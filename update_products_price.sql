create or replace procedure actualiza_price()
returns varchar
EXECUTE AS CALLER
as
BEGIN

create or replace temporary table DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products_price as (
    select 
        row_number() over (order by product_id) as row_number,
        product_id,
        price
    
     from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PRODUCTS 
);

LET num_products NUMBER := (select max(row_number) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products_price);

begin
  for i in 1 to :num_products do
  
  let product_id varchar := (select product_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products_price where row_number=:i);
  
  update DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PRODUCTS
    set
        price = round(normal((select avg(price) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PRODUCTS),10,random())),
        _fivetran_synced = current_timestamp()
    where product_id = :product_id;    

  end for;
end;

drop table DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products_price;

END;
