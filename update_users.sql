-- Actualiza la address_id de 4 usuarios al azar en la tabla users

begin
 for i in 1 to 4 do
   
  set random_user_id = (select user_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.USERS sample row (1 rows));
  set address_id = (select address_id from DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.addresses sample row (1 rows));
  
  update DEV_BRONZE_DB_ALUMNO18.SQL_SERVER_DBO.users
  set
    address_id = $address_id,
    updated_at = current_timestamp(),
    _fivetran_synced = current_timestamp()
  where user_id = $random_user_id;    

 end for;
end;
