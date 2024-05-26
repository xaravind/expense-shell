#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo "please enter root password"
read -s mysql_root_password

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "dibaling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enabling nodejs:20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "installing nodejs"

id expense  &>>$LOGFILE
if [ $? -ne 0 ]
then 
  useradd expense  &>>$LOGFILE
  VALIDATE $? "creating user"
else
  echo -e " user already exsists... $Y SKIPPING $N"
fi

mkdir -p /app  &>>$LOGFILE # -p will skip if directory already exisit 
VALIDATE $? "creating directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOGFILE
VALIDATE $? "downloding code"

cd /app  &>>$LOGFILE
rm -rf /app/*  &>>$LOGFILE
unzip /tmp/backend.zip  &>>$LOGFILE
VALIDATE $? "extacing code"

npm install  &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user//expense-shell/backend.service /etc/systemd/system/  &>>$LOGFILE
VALIDATE $? "copying file backend.service"

systemctl daemon-reload  &>>$LOGFILE
VALIDATE $? "daemon-reload"

systemctl start backend  &>>$LOGFILE
VALIDATE $? "starting backend"

systemctl enable backend  &>>$LOGFILE
VALIDATE $? "enabling backend"

dnf install mysql -y  &>>$LOGFILE
VALIDATE $? "installing mysql client"

mysql -h db.dopspractice.online -uroot -p${mysql_root_password} < /app/schema/backend.sql  &>>$LOGFILE
VALIDATE $? "loading schema"

systemctl restart backend  &>>$LOGFILE
VALIDATE $? "restaring backend"



