use dev_bronze_db_alumno18.google_sheets;

BEGIN
create or replace temporary table temp_budget(_row number identity(1,1), quantity number, month date, product_id varchar, _fivetran_synced timestamp_tz);

create or replace temporary table DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products as (
    select 
        row_number() over (order by product_id) as row_number,
        product_id
    
     from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.PRODUCTS 
);

    let num_products number := (select max(row_number) from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products);
    let product_id varchar := null;
    
begin
  for i in 1 to 3 do
  let month date := dateadd(month,:i,current_date());
  
    begin
      for i in 1 to :num_products do

      let product_id varchar := (select product_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.temp_products where row_number=:i);
      let quantity number := (select round(normal((select avg(quantity) from DEV_BRONZE_DB_ALUMNO18.GOOGLE_SHEETS.BUDGET),1.5,random())));

      insert into temp_budget (quantity, month, product_id, _fivetran_synced) 
      values (
          :quantity,
          :month,
          :product_id,
          current_timestamp()
      );

      end for;
    end;
    
  end for;
end;
END;

select * from temp_budget;
