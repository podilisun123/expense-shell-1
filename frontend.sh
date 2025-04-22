#!/bin/bash
USER=$(id -u)
TIME_STAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/${SCRIPT_NAME}-${TIME_STAMP}.log

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
dnf install nginx -y &>>$LOGFILE
validate $? "installing nginx"
systemctl enable nginx &>>$LOGFILE
validate $? "enabling nginx"
systemctl start nginx &>>$LOGFILE
validate $? "start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
validate $? "remove default html code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
validate $? "download the code "

cd /usr/share/nginx/html
unzip /tmp/frontend.zip &>>$LOGFILE
validate $? "unzipping the code"

cp /home/ec2-user/expense-shell-1/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
systemctl restart nginx &>>$LOGFILE
validate $? "restart nginx"