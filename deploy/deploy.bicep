param prefix string = 'academo'
param location string = resourceGroup().location
param sourceRepo string = 'https://github.com/ScottHolden/ACAFrontBackSvcDemo.git'

var uniqueName = '${prefix}${uniqueString(prefix, resourceGroup().id, location)}'

module environment 'modules/environment.bicep' = {
  name: '${uniqueName}-environment'
  params: {
    location: location
    uniqueName: uniqueName
  }
}

module servicebus 'modules/servicebus.bicep' = {
  name: '${uniqueName}-servicebus'
  params: {
    location: location
    uniqueName: uniqueName
  }
}

module service 'container-apps/service.bicep' = {
  name: '${uniqueName}-service'
  params: {
    prefix: prefix
    containerAppsEnvId: environment.outputs.cappsEnvId
    containerRegistryName: environment.outputs.containerRegistryName
    containerPullIdentityId: environment.outputs.containerPullIdentityId
    sbName: servicebus.outputs.sbName
    sbQueueName: servicebus.outputs.queueName
    location: location
    sourceRepo: sourceRepo
  }
}

module frontend 'container-apps/frontend.bicep' = {
  name: '${uniqueName}-frontend'
  params: {
    prefix: prefix
    containerAppsEnvId: environment.outputs.cappsEnvId
    containerRegistryName: environment.outputs.containerRegistryName
    containerPullIdentityId: environment.outputs.containerPullIdentityId
    location: location
    sourceRepo: sourceRepo
  }
}

module backend 'container-apps/backend.bicep' = {
  name: '${uniqueName}-backend'
  params: {
    prefix: prefix
    containerAppsEnvId: environment.outputs.cappsEnvId
    containerRegistryName: environment.outputs.containerRegistryName
    containerPullIdentityId: environment.outputs.containerPullIdentityId
    sbName: servicebus.outputs.sbName
    sbQueueName: servicebus.outputs.queueName
    location: location
    sourceRepo: sourceRepo
  }
}
