

#!/bin/bash



# Set the Kafka broker host and port

KAFKA_BROKER_HOST=${BROKER_HOST}

KAFKA_BROKER_PORT=${BROKER_PORT}



# Check if the Kafka broker host is reachable via ping

ping -c 4 $KAFKA_BROKER_HOST



# Check if the Kafka broker port is open and listening

nc -zv $KAFKA_BROKER_HOST $KAFKA_BROKER_PORT



# Check if the liveness check service can connect to the Kafka broker host and port

telnet $KAFKA_BROKER_HOST $KAFKA_BROKER_PORT