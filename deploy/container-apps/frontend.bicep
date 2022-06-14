param containerAppsEnvId string
param containerRegistryName string
param containerPullIdentityId string
param location string
param sourceRepo string
param prefix string

var name = 'frontend'
var dockerFilePath = 'src/ACADemo.FrontEnd/Dockerfile'

module build '../modules/buildtask.bicep' = {
  name: '${deployment().name}-build'
  params: {
    containerRegistryName: containerRegistryName
    imageName: '${prefix}/${name}:v1'
    sourceRepo: sourceRepo
    dockerFilePath: dockerFilePath
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: '${prefix}-${name}'
  location: location
  properties: {
    managedEnvironmentId: containerAppsEnvId
    configuration: {
      ingress: {
        external: true
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
        appId: 'frontend'
        appPort: 80
        appProtocol: 'http'
      }
    }
    template: {
      containers: [
        {
          name: name
          image: build.outputs.containerImage
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
