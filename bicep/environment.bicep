param environmentName string
param logAnalyticsWorkspaceName string = 'logs-${environmentName}'
param appInsightsName string = 'appins-${environmentName}'
param location string = resourceGroup().location
param vaultName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
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
  name: appInsightsName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
  }
}

resource environment 'Microsoft.Web/kubeEnvironments@2021-02-01' = {
  name: environmentName
  location: location
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    containerAppsConfiguration: {
      daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    }
  }
}
resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing =  {
  name: vaultName

  resource environmentIdSecret 'secrets' = {
    name: 'environmentId'
    properties: {
      value: environment.id
    }
  }
  resource appInsightsInstrumentationKeySecret 'secrets' = {
    name: 'appInsightsInstrumentationKey'
    properties: {
      value: appInsights.properties.InstrumentationKey
    }
  } 
}
