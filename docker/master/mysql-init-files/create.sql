CREATE DATABASE community;

##create masteruser and grant privileges
grant all privileges on community.* to community@'%' identified by 'rootpassword';

#replication
grant replication slave on *.* to 'community'@'%';

## flushj
flush privileges;
