param uniqueName string
param location string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: uniqueName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
  }
}

resource containerPullIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: '${uniqueName}-containerpull'
  location: location
}

resource containerPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // ACR Pull
}

resource containerPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(uniqueName, containerPullIdentity.id, containerPullRoleDefinition.id)
  properties: {
    principalId: containerPullIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: containerPullRoleDefinition.id
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: uniqueName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: uniqueName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource containerAppsEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: uniqueName
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

output cappsEnvId string = containerAppsEnv.id
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output defaultDomain string = containerAppsEnv.properties.defaultDomain
output containerRegistryName string = containerRegistry.name
output containerPullIdentityId string = containerPullIdentity.id
