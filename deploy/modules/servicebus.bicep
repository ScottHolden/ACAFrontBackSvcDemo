param uniqueName string
param location string
param queueName string = 'service'

resource servicebus 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: uniqueName
  location: location
  properties: {
  }
  resource queue 'queues@2021-11-01' = {
    name: queueName
    properties: {
    }
  }
}

output sbName string = servicebus.name
output queueName string = servicebus::queue.name
