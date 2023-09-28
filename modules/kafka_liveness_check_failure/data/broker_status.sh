

#!/bin/bash



#Set variables

BROKER_HOST=${BROKER_HOST} 

BROKER_PORT=${BROKER_PORT}



#Check CPU utilization

CPU_UTIL=$(ssh $BROKER_HOST "top -bn1 | grep 'Cpu(s)' | awk '{print $2+$4}'")



if (( $(echo "$CPU_UTIL > 80" | bc -l) )); then

    echo "WARNING: High CPU utilization on $BROKER_HOST. Current CPU utilization is $CPU_UTIL%"

fi



#Check memory utilization

MEMORY_UTIL=$(ssh $BROKER_HOST "free | awk '/Mem:/ {print $3/$2 * 100.0}'")



if (( $(echo "$MEMORY_UTIL > 80" | bc -l) )); then

    echo "WARNING: High memory utilization on $BROKER_HOST. Current memory utilization is $MEMORY_UTIL%"

fi



#Check Kafka broker status

KAFKA_STATUS=$(ssh $BROKER_HOST "systemctl status kafka")



if [[ "$KAFKA_STATUS" != *"active (running)"* ]]; then

    echo "ERROR: Kafka broker is not running on $BROKER_HOST. Status: $KAFKA_STATUS"

fi



#Check Kafka broker port

KAFKA_PORT_STATUS=$(nc -zv $BROKER_HOST $BROKER_PORT 2>&1)



if [[ "$KAFKA_PORT_STATUS" == *"Connection refused"* ]]; then

    echo "ERROR: Kafka broker port $BROKER_PORT is not open on $BROKER_HOST"

fi