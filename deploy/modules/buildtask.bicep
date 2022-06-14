param containerRegistryName string
param sourceRepo string
param imageName string
param dockerFilePath string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryName
}

resource buildTask 'Microsoft.ContainerRegistry/registries/taskRuns@2019-06-01-preview' = {
  name: uniqueString(imageName)
  parent: containerRegistry
  properties: {
    runRequest: {
      type: 'DockerBuildRequest'
      dockerFilePath: dockerFilePath
      imageNames: [
        imageName
      ]
      isPushEnabled: true
      sourceLocation: sourceRepo
      platform: {
        os: 'Linux'
        architecture: 'amd64'
      }
      agentConfiguration: {
        cpu: 2
      }
    }
  }
}

output containerImageServer string = containerRegistry.properties.loginServer
output containerImage string = '${containerRegistry.properties.loginServer}/${imageName}'
