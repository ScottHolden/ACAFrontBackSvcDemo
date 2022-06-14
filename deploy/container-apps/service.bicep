param containerAppsEnvId string
param containerRegistryName string
param containerPullIdentityId string
param sbName string
param sbQueueName string
param location string
param sourceRepo string
param prefix string

var name = 'service'
var dockerFilePath = 'src/ACADemo.Service/Dockerfile'

module build '../modules/buildtask.bicep' = {
  name: '${deployment().name}-build'
  params: {
    containerRegistryName: containerRegistryName
    imageName: '${prefix}/${name}:v1'
    sourceRepo: sourceRepo
    dockerFilePath: dockerFilePath
  }
}

resource servicebus 'Microsoft.ServiceBus/namespaces@2021-11-01' existing = {
  name: sbName
  resource queue 'queues@2021-11-01' existing = {
    name: sbQueueName
  }
}

resource sbReceiverRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0' // Azure Service Bus Data Receiver
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: servicebus::queue
  name: guid(containerApp.id, sbReceiverRoleDefinition.id)
  properties: {
    roleDefinitionId: sbReceiverRoleDefinition.id
    principalId: containerApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: '${prefix}-${name}'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvId
    configuration: {
      ingress: null
      registries: [
        {
          server: build.outputs.containerImageServer
          identity: containerPullIdentityId
        }
      ]
    }
    template: {
      containers: [
        {
          name: name
          image: build.outputs.containerImage
          env: [
            {
              name: 'sb-queue'
              value: sbQueueName
            }
            {
              name: 'sb-namespace'
              value: servicebus.properties.serviceBusEndpoint
            }
          ]
          resources: {
            cpu: any('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${containerPullIdentityId}': {}
    }
  }
}
