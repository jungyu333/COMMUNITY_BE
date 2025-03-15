CREATE DATABASE IF NOT EXISTS community;

## Create Slave User
CREATE USER 'community'@'%' IDENTIFIED BY 'rootpassword';
GRANT ALL PRIVILEGES ON community.* TO 'community'@'%';
GRANT REPLICATION SLAVE ON *.* TO 'community'@'%';


## 적용
FLUSH PRIVILEGES;