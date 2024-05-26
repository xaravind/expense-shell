#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing my sql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "enabling my sql server"

systemctl start mysqld &>>$LOGFILE 
VALIDATE $? "starting my sql server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "setting up root server"

#Below code will be useful for idempotent nature
mysql -h db.dopspractice.online -uroot -pExpenseApp@1 -e 'SHOW DATABASES;' &>>$LOGFILE
if [ $? -ne 0 ]
then
  mysql_secure_installation --set-root-pass ExpenseApp@1
  VALIDATE $? "Setting up root password"
else
  echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi

