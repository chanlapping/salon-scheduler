#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

GET_SERVICE() {
  echo -e "\nChoose a service:"
  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    GET_SERVICE
  else
    REQUEST=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $REQUEST ]]
    then
      GET_SERVICE
    fi
  fi
}

GET_CUSTOMER_INFO() {
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  # if not found
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get customer name
    echo -e "\nPlease enter your name:"
    read CUSTOMER_NAME
    INSERT_NEW_CUSTOMER
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
}

INSERT_NEW_CUSTOMER() {
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
}

GET_TIME() {
  echo -e "\nPlease enter service time:"
  read SERVICE_TIME
}

MAKE_APPOINTMENT() {
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

}

OUTPUT_MESSAGE() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

GET_SERVICE
GET_CUSTOMER_INFO
GET_TIME
MAKE_APPOINTMENT
OUTPUT_MESSAGE
