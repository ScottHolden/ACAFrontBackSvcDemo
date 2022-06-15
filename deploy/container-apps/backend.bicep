param containerAppsEnvId string
param containerRegistryName string
param containerPullIdentityId string
param sbName string
param sbQueueName string
param location string
param sourceRepo string
param prefix string

var name = 'backend'
var dockerFilePath = 'src/ACADemo.BackEnd/Dockerfile'

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

resource sbSenderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39' // Azure Service Bus Data Sender
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: servicebus::queue
  name: guid(containerApp.id, sbSenderRoleDefinition.id)
  properties: {
    roleDefinitionId: sbSenderRoleDefinition.id
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
      ingress: {
        external: false
        targetPort: 80
      }
      registries: [
        {
          server: build.outputs.containerImageServer
          identity: containerPullIdentityId
        }
      ]
      dapr: {
        enabled: true
        appId: 'backend'
        appPort: 80
        appProtocol: 'http'
      }
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
              value: '${sbName}.servicebus.windows.net'
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
