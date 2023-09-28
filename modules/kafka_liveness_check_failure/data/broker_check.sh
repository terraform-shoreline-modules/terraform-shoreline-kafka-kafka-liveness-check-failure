bash

#!/bin/bash

# Define variables

BROKER_HOST=${BROKER_HOST}

BROKER_PORT=${BROKER_PORT}



# Check if broker is running

nc -z -v $BROKER_HOST $BROKER_PORT

if [ $? -eq 0 ]; then

    echo "Broker is running on $BROKER_HOST"

else

    echo "Broker is not running on $BROKER_HOST"

    # Start the broker

    sudo systemctl start kafka

    echo "Started Kafka broker on $BROKER_HOST"

fi