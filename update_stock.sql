create or replace procedure actualiza_stock()
returns varchar
EXECUTE AS CALLER
as
BEGIN
 
create or replace temporary table DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products as (
    select 
        row_number() over (order by product_id) as row_number,
        product_id,
        inventory
    
     from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PRODUCTS 
);

    let num_products number := (select max(row_number) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products);
    let product_id varchar := null;

begin
  for i in 1 to :num_products do
  
    set product_id = (select product_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products where row_number=:i);
  
  update DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PRODUCTS
    set
        inventory = round(normal((select avg(inventory) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PRODUCTS),6,random())),
        _fivetran_synced = current_timestamp()
    where product_id = :product_id;    

  end for;
end;

drop table DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products;

END;
