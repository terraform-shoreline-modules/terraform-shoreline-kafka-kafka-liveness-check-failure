resource "shoreline_notebook" "kafka_liveness_check_failure" {
  name       = "kafka_liveness_check_failure"
  data       = file("${path.module}/data/kafka_liveness_check_failure.json")
  depends_on = [shoreline_action.invoke_kafka_broker_check,shoreline_action.invoke_cpu_memory_kafka_check,shoreline_action.invoke_check_broker]
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

resource "shoreline_file" "cpu_memory_kafka_check" {
  name             = "cpu_memory_kafka_check"
  input_file       = "${path.module}/data/cpu_memory_kafka_check.sh"
  md5              = filemd5("${path.module}/data/cpu_memory_kafka_check.sh")
  description      = "The broker host is experiencing high CPU or memory utilization that is causing it to be unresponsive."
  destination_path = "/agent/scripts/cpu_memory_kafka_check.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "check_broker" {
  name             = "check_broker"
  input_file       = "${path.module}/data/check_broker.sh"
  md5              = filemd5("${path.module}/data/check_broker.sh")
  description      = "Check if the broker is running on the host specified in the configuration file. If not, start the broker on the specified host."
  destination_path = "/agent/scripts/check_broker.sh"
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

resource "shoreline_action" "invoke_cpu_memory_kafka_check" {
  name        = "invoke_cpu_memory_kafka_check"
  description = "The broker host is experiencing high CPU or memory utilization that is causing it to be unresponsive."
  command     = "`chmod +x /agent/scripts/cpu_memory_kafka_check.sh && /agent/scripts/cpu_memory_kafka_check.sh`"
  params      = ["BROKER_HOST","BROKER_PORT"]
  file_deps   = ["cpu_memory_kafka_check"]
  enabled     = true
  depends_on  = [shoreline_file.cpu_memory_kafka_check]
}

resource "shoreline_action" "invoke_check_broker" {
  name        = "invoke_check_broker"
  description = "Check if the broker is running on the host specified in the configuration file. If not, start the broker on the specified host."
  command     = "`chmod +x /agent/scripts/check_broker.sh && /agent/scripts/check_broker.sh`"
  params      = ["BROKER_HOST","BROKER_PORT"]
  file_deps   = ["check_broker"]
  enabled     = true
  depends_on  = [shoreline_file.check_broker]
}

