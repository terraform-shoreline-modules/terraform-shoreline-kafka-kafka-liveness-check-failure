
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kafka liveness check failure.
---

This incident type refers to a scenario where the liveness check for Kafka cannot reach/communicate with the host where the broker is running. This issue can arise due to various reasons such as network issues, broker failure, or configuration errors. This can result in the Kafka broker being unavailable or not responding to requests, leading to potential service disruptions or downtime.

### Parameters
```shell
export ZK_HOST="PLACEHOLDER"

export ZK_PORT="PLACEHOLDER"

export BROKER_PORT="PLACEHOLDER"

export BROKER_HOST="PLACEHOLDER"

export TOPIC_NAME="PLACEHOLDER"
```

## Debug

### Check if Zookeeper is running on the specified <zk_host> and <zk_port>
```shell
echo ruok | nc ${ZK_HOST} ${ZK_PORT}
```

### Check the status of all Kafka brokers
```shell
bin/kafka-broker-api-versions.sh --bootstrap-server ${BROKER_HOST}:${BROKER_PORT}
```

### Check if the Kafka broker is running on the specified <broker_host> and <broker_port>
```shell
echo "stats" | nc ${BROKER_HOST} ${BROKER_PORT}
```

### Check if the Kafka broker is registered with Zookeeper
```shell
bin/kafka-topics.sh --list --zookeeper ${ZK_HOST}:${ZK_PORT}
```

### Check if the Kafka topics are being replicated correctly
```shell
bin/kafka-replica-verification.sh --broker-list ${BROKER_HOST}:${BROKER_PORT} --topic ${TOPIC_NAME}
```

### Check if the Kafka producer is able to send messages to the broker
```shell
bin/kafka-console-producer.sh --broker-list ${BROKER_HOST}:${BROKER_PORT} --topic ${TOPIC_NAME}
```

### Check if the Kafka consumer is able to receive messages from the broker
```shell
bin/kafka-console-consumer.sh --bootstrap-server ${BROKER_HOST}:${BROKER_PORT} --topic ${TOPIC_NAME}
```

### Network connectivity issues between the liveness check service and the broker host.
```shell


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


```

### The broker host is experiencing high CPU or memory utilization that is causing it to be unresponsive.
```shell


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


```

## Repair

### Check if the broker is running on the host specified in the configuration file. If not, start the broker on the specified host.
```shell
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


```