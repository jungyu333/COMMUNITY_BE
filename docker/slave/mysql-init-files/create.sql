CREATE DATABASE community;

#create masteruser and grant privileges
create user community@'%' identified by 'rootpassword';

grant all privileges on community.* to community@'%' identified by 'rootpassword';

## flush
flush privileges;
