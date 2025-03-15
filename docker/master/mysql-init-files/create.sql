CREATE DATABASE community;

##create masteruser and grant privileges
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'rootpassword' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.21.0.1' IDENTIFIED BY 'rootpassword' WITH GRANT OPTION;

#replication
grant replication slave on *.* to 'community'@'%';

## flush
flush privileges;
