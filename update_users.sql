create or replace procedure actualiza_users()
returns varchar
EXECUTE AS CALLER
as
begin
 for i in 1 to 4 do
   
  LET random_user_id VARCHAR := (select user_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.USERS sample row (1 rows));
  LET address_id VARCHAR := (select address_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.addresses sample row (1 rows));
  
  update DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.users
  set
    address_id = :address_id,
    updated_at = current_timestamp(),
    _fivetran_synced = current_timestamp()
  where user_id = :random_user_id;    

 end for;
end;
