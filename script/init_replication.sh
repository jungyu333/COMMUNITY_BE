#!/bin/bash

MASTER_IP="mysql-master"
SLAVE_IP='mysql-slave'
MYSQL_ROOT_PASSWORD="community"
REPL_USER="replica_user"
REPL_PASSWORD="replica123"

echo "🐳 Docker Run"
docker-compose -f docker/docker-compose.yml -p community up -d

echo "⏳ Wait MySQL Slave"
while ! docker exec $SLAVE_IP mysqladmin -uroot -p$MYSQL_ROOT_PASSWORD ping -h127.0.0.1 --silent; do
    echo "⏳ Slave Waiting"
    sleep 2
done

echo "✅ MySQL Slave Ready"

echo "🔧 Create Replica User"
docker exec mysql-master mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "
CREATE USER '$REPL_USER'@'%' IDENTIFIED BY '$REPL_PASSWORD';
GRANT REPLICATION SLAVE ON *.* TO '$REPL_USER'@'%';
FLUSH PRIVILEGES;"


echo "📜 Get Master Binary Log"
MASTER_STATUS=$(docker exec mysql-master mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "SHOW MASTER STATUS\G")
BINLOG_FILE=$(echo "$MASTER_STATUS" | grep "File" | awk '{print $2}')
BINLOG_POS=$(echo "$MASTER_STATUS" | grep "Position" | awk '{print $2}')

echo "🎯 Master Binlog File: $BINLOG_FILE"
echo "🎯 Master Binlog Position: $BINLOG_POS"

echo "🔄 Set Replica"
docker exec mysql-slave mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "
STOP SLAVE;
CHANGE MASTER TO
    MASTER_HOST='$MASTER_IP',
    MASTER_USER='$REPL_USER',
    MASTER_PASSWORD='$REPL_PASSWORD',
    MASTER_LOG_FILE='$BINLOG_FILE',
    MASTER_LOG_POS=$BINLOG_POS;
START SLAVE;
SHOW SLAVE STATUS\G"

echo "✅ Master-Slave Replication Complete"
