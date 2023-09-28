resource "shoreline_notebook" "kafka_liveness_check_failure" {
  name       = "kafka_liveness_check_failure"
  data       = file("${path.module}/data/kafka_liveness_check_failure.json")
  depends_on = [shoreline_action.invoke_kafka_broker_check,shoreline_action.invoke_broker_status,shoreline_action.invoke_broker_check]
}

resource "shoreline_file" "kafka_broker_check" {
  name             = "kafka_broker_check"
  input_file       = "${path.module}/data/kafka_broker_check.sh"
  md5              = filemd5("${path.module}/data/kafka_broker_check.sh")
  description      = "Network connectivity issues between the liveness check service and the broker host."
  destination_path = "/agent/scripts/kafka_broker_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "broker_status" {
  name             = "broker_status"
  input_file       = "${path.module}/data/broker_status.sh"
  md5              = filemd5("${path.module}/data/broker_status.sh")
  description      = "The broker host is experiencing high CPU or memory utilization that is causing it to be unresponsive."
  destination_path = "/agent/scripts/broker_status.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "broker_check" {
  name             = "broker_check"
  input_file       = "${path.module}/data/broker_check.sh"
  md5              = filemd5("${path.module}/data/broker_check.sh")
  description      = "Check if the broker is running on the host specified in the configuration file. If not, start the broker on the specified host."
  destination_path = "/agent/scripts/broker_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_kafka_broker_check" {
  name        = "invoke_kafka_broker_check"
  description = "Network connectivity issues between the liveness check service and the broker host."
  command     = "`chmod +x /agent/scripts/kafka_broker_check.sh && /agent/scripts/kafka_broker_check.sh`"
  params      = ["BROKER_HOST","BROKER_PORT"]
  file_deps   = ["kafka_broker_check"]
  enabled     = true
  depends_on  = [shoreline_file.kafka_broker_check]
}

resource "shoreline_action" "invoke_broker_status" {
  name        = "invoke_broker_status"
  description = "The broker host is experiencing high CPU or memory utilization that is causing it to be unresponsive."
  command     = "`chmod +x /agent/scripts/broker_status.sh && /agent/scripts/broker_status.sh`"
  params      = ["BROKER_HOST","BROKER_PORT"]
  file_deps   = ["broker_status"]
  enabled     = true
  depends_on  = [shoreline_file.broker_status]
}

resource "shoreline_action" "invoke_broker_check" {
  name        = "invoke_broker_check"
  description = "Check if the broker is running on the host specified in the configuration file. If not, start the broker on the specified host."
  command     = "`chmod +x /agent/scripts/broker_check.sh && /agent/scripts/broker_check.sh`"
  params      = ["BROKER_HOST","BROKER_PORT"]
  file_deps   = ["broker_check"]
  enabled     = true
  depends_on  = [shoreline_file.broker_check]
}

