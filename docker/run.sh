###!/bin/bash
##docker-compose -f ./docker/docker-compose.yml up -d
##
##sleep 5
##
##master_log_file=`mysql -h127.0.0.1 --port 33306 -uroot -ppassword -e "show master status\G" | grep mysql-bin`
##master_log_file=${master_log_file}
##
##
##
##master_log_file=${master_log_file//[[:blank:]]/}
##
##master_log_file=${${master_log_file}#File:}
##
##echo ${master_log_file}
##
##master_log_pos=`mysql -h127.0.0.1 --port 33306  -uroot -ppassword -e "show master status\G" | grep Position`
##master_log_pos=${master_log_pos}
##
##
##master_log_pos=${master_log_pos//[[:blank:]]/}
##
##master_log_pos=${${master_log_pos}#Position:}
##
##echo ${master_log_pos}
##
##
##query="CHANGE MASTER TO MASTER_HOST='community_master', MASTER_USER='community', MASTER_PASSWORD='rootpassword', MASTER_LOG_FILE='${master_log_file}', MASTER_LOG_POS=${master_log_pos} ,master_port=33306"
##
##
##mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "stop slave"
##mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "${query}"
##mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "start slave"
##!/bin/bash
#
#echo "🚀 MySQL Master-Slave Replication 자동화 시작..."
#
## 1️⃣ Docker Compose 실행 (백그라운드)
#docker-compose -f ./docker/docker-compose.yml up -d
#
## 2️⃣ MySQL이 정상 실행될 때까지 대기
#echo "⏳ MySQL 컨테이너가 시작될 때까지 대기..."
#sleep 10
#
## 3️⃣ Master 상태 확인 및 로그 파일 / 포지션 가져오기
#echo "🔍 Master 상태 확인 중..."
#MASTER_LOG=$(mysql -h127.0.0.1 --port 33306 -uroot -prootpassword -e "SHOW MASTER STATUS\G")
#
## 로그 파일과 위치 추출
#master_log_file=$(echo "$MASTER_LOG" | grep "File:" | awk '{print $2}')
#master_log_pos=$(echo "$MASTER_LOG" | grep "Position:" | awk '{print $2}')
#
## 값이 없는 경우 오류 처리
#if [[ -z "$master_log_file" || -z "$master_log_pos" ]]; then
#    echo "❌ Master Log 정보가 없습니다. Binary Logging이 활성화되어 있는지 확인하세요."
#    exit 1
#fi
#
#echo "✅ Master Log File: ${master_log_file}"
#echo "✅ Master Log Position: ${master_log_pos}"
#
## 4️⃣ Master 설정이 완료될 때까지 대기 (슬레이브가 정상적으로 연결되도록 보장)
#echo "⏳ Master 설정 완료 대기..."
#sleep 5
#
## 5️⃣ Slave 설정 (실제 Master 호스트 IP 가져오기)
#MYSQL_MASTER_HOST="community_master"
#
#echo "🔗 Slave에 Master 연결 설정 중..."
#CHANGE_MASTER_QUERY="CHANGE MASTER TO
#    MASTER_HOST='${MYSQL_MASTER_HOST}',
#    MASTER_USER='community',
#    MASTER_PASSWORD='rootpassword',
#    MASTER_LOG_FILE='${master_log_file}',
#    MASTER_LOG_POS=${master_log_pos},
#    MASTER_PORT=33306;"
#
#mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "STOP SLAVE;"
#mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "$CHANGE_MASTER_QUERY"
#mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "START SLAVE;"
#
## 6️⃣ Slave 동작 상태 확인
#SLAVE_STATUS=$(mysql -h127.0.0.1 --port 43306 -uroot -prootpassword -e "SHOW SLAVE STATUS\G")
#
#if echo "$SLAVE_STATUS" | grep -q "Slave_IO_Running: Yes" && echo "$SLAVE_STATUS" | grep -q "Slave_SQL_Running: Yes"; then
#    echo "✅ Master-Slave 복제 설정 완료!"
#else
#    echo "❌ Slave가 정상적으로 동작하지 않습니다. 로그를 확인하세요."
#    exit 1
#fi
#!/bin/bash

echo "🚀 MySQL Master-Slave Replication 자동화 시작..."

# 1️⃣ Docker Compose 실행 (백그라운드)
docker-compose -f ./docker/docker-compose.yml up -d

# 2️⃣ MySQL이 정상 실행될 때까지 대기
echo "⏳ MySQL 컨테이너가 시작될 때까지 대기..."
sleep 10

# 3️⃣ Master의 실제 IP 가져오기
MYSQL_MASTER_HOST=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' community_master)
echo "🔍 Master IP: ${MYSQL_MASTER_HOST}"

# 4️⃣ MySQL Root 패스워드 가져오기
#ROOT_PASSWORD=$(cat /run/secrets/mariadb_root_password)

# 5️⃣ Master 상태 확인 및 로그 파일 / 포지션 가져오기
echo "🔍 Master 상태 확인 중..."
MASTER_LOG=$(mysql -h127.0.0.1 --port 33306 -uroot -prootpassword -e "SHOW MASTER STATUS\G")

# 로그 파일과 위치 추출
master_log_file=$(echo "$MASTER_LOG" | grep "File:" | awk '{print $2}')
master_log_pos=$(echo "$MASTER_LOG" | grep "Position:" | awk '{print $2}')

# 값이 없는 경우 오류 처리
if [[ -z "$master_log_file" || -z "$master_log_pos" ]]; then
    echo "❌ Master Log 정보가 없습니다. Binary Logging이 활성화되어 있는지 확인하세요."
    exit 1
fi

echo "✅ Master Log File: ${master_log_file}"
echo "✅ Master Log Position: ${master_log_pos}"

# 6️⃣ Master의 bind-address 설정 (외부 연결 허용)
echo "🔧 Master bind-address 설정 변경..."
docker exec -it community_master bash -c "echo '[mysqld]\nbind-address = 0.0.0.0' > /etc/mysql/conf.d/bind.cnf"
docker restart community_master
sleep 5

# 7️⃣ Slave 설정 (Master 연결 테스트)
echo "🔗 Slave에서 Master 연결 테스트..."
if ! mysql -uroot -prootpassword -h"${MYSQL_MASTER_HOST}" -P 33306 -e "SHOW MASTER STATUS;" > /dev/null 2>&1; then
    echo "❌ Master에 접속할 수 없습니다. 네트워크를 확인하세요."
    exit 1
fi

# 8️⃣ Slave에 Master 설정 적용
echo "🔗 Slave에 Master 연결 설정 중..."
CHANGE_MASTER_QUERY="CHANGE MASTER TO
    MASTER_HOST='${MYSQL_MASTER_HOST}',
    MASTER_USER='community',
    MASTER_PASSWORD='rootpassword',
    MASTER_LOG_FILE='${master_log_file}',
    MASTER_LOG_POS=${master_log_pos},
    MASTER_PORT=33306;"

mysql -h127.0.0.1 --port 43306 -uroot -p"${ROOT_PASSWORD}" -e "STOP SLAVE;"
mysql -h127.0.0.1 --port 43306 -uroot -p"${ROOT_PASSWORD}" -e "${CHANGE_MASTER_QUERY}"
mysql -h127.0.0.1 --port 43306 -uroot -p"${ROOT_PASSWORD}" -e "START SLAVE;"

# 9️⃣ Slave 동작 상태 확인
SLAVE_STATUS=$(mysql -h127.0.0.1 --port 43306 -uroot -p"${ROOT_PASSWORD}" -e "SHOW SLAVE STATUS\G")

if echo "$SLAVE_STATUS" | grep -q "Slave_IO_Running: Yes" && echo "$SLAVE_STATUS" | grep -q "Slave_SQL_Running: Yes"; then
    echo "✅ Master-Slave 복제 설정 완료!"
else
    echo "❌ Slave가 정상적으로 동작하지 않습니다. 로그를 확인하세요."
    exit 1
fi
