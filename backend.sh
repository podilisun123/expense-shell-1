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
        echo -e "$2.. $R..FAILURE $N"
        exit 1
    else 
        echo -e "$2 ..$G SUCCESS $N"
    fi
}
dnf module disable nodejs -y &>>$LOGFILE
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
validate $? "enabling nodejs"

dnf install nodejs -y &>>$LOGFILE
validate $? "instaling nodejs"

id expense &>>$LOGFILE

if [ $? -ne 0 ]
then 
    useradd expense &>>$LOGFILE
    validate $? "creating expense user"
else
    echo -e "expense user already created $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
validate $? "creating application directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
validate $? "downloading nodejs code"

cd /app 
rm -rf /app/*

unzip /tmp/backend.zip &>>$LOGFILE
validate $? "unzip the backend code"
npm install &>>$LOGFILE
validate $? "downloading node js dependencies"

cp /home/ec2-user/expense-shell-1/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
validate $? "create backend service"
systemctl daemon-reload &>>$LOGFILE
validate $? "daemon reload"
systemctl start backend &>>$LOGFILE
validate $? "starting backend"
systemctl enable backend &>>$LOGFILE
validate $? "enabling backend"
dnf install mysql -y &>>$LOGFILE
validate $? "installing mysql client"
mysql -h db.sundardev.online -uroot -p${DB_PASSWORD} < /app/schema/backend.sql &>>$LOGFILE
validate $? "loading schema"
systemctl restart backend