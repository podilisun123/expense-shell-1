#!/bin/bash
USER=$(id -u)
TIME_STAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/${SCRIPT_NAME}-${TIME_STAMP}.log

read  -s -p "enter db password:" DB_PASSWORD 

if [ $USER -ne 0 ]
then 
    echo "you should make root user"
    exit 1
else
    echo "you are super user"
fi

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
validate(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 installation $R..FAILURE $N"
        exit 1
    else 
        echo -e "$2 installation ..$G SUCCESS $N"
    fi
}

dnf install mysql-server -y &>>$LOGFILE
validate $? "installing mysql"

systemctl start mysqld &>>$LOGFILE
validate $? "starting mysql"


mysql -h db.sundardev.online -uroot -p${DB_PASSWORD} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${DB_PASSWORD} &>>$LOGFILE
    validate $? "setting root password"
else
    echo -e "setting root password already done:$Y SKIPPING $N"
fi