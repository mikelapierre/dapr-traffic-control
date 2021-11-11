param location string
param vaultName string
param tenantId string
param objectId string
param registryServer string
param registryUsername string
param registryPassword string
param environmentId string
param serviceBusConnectionString string
param storageAccountName string
param storageAccountKey string
param eventHubNsConnectionString string
param entrycamConnectionString string
param exitcamConnectionString string
param appInsightsInstrumentationKey string
param maildevHost string

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: vaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: objectId
        permissions: {
          certificates: []
          keys: []
          secrets: [ 
            'get'
            'list' 
          ]
          storage: []
        }
        tenantId: tenantId
      }
    ]
    enableSoftDelete: false
  }

  resource registryServerSecret 'secrets' = {
    name: 'registryServer'
    properties: {
      value: registryServer
    }
  }
  resource registryUsernameSecret 'secrets' = {
    name: 'registryUsername'
    properties: {
      value: registryUsername
    }
  }
  resource registryPasswordSecret 'secrets' = {
    name: 'registryPassword'
    properties: {
      value: registryPassword
    }
  }
  resource environmentIdSecret 'secrets' = {
    name: 'environmentId'
    properties: {
      value: environmentId
    }
  }  
  resource serviceBusConnectionStringSecret 'secrets' = {
    name: 'serviceBusConnectionString'
    properties: {
      value: serviceBusConnectionString
    }
  }  
  resource storageAccountNameSecret 'secrets' = {
    name: 'storageAccountName'
    properties: {
      value: storageAccountName
    }
  } 
  resource storageAccountKeySecret 'secrets' = {
    name: 'storageAccountKey'
    properties: {
      value: storageAccountKey
    }
  }  
  resource eventHubNsConnectionStringSecret 'secrets' = {
    name: 'eventHubNsConnectionString'
    properties: {
      value: eventHubNsConnectionString
    }
  } 
  resource entrycamConnectionStringSecret 'secrets' = {
    name: 'entrycamConnectionString'
    properties: {
      value: entrycamConnectionString
    }
  } 
  resource exitcamConnectionStringSecret 'secrets' = {
    name: 'exitcamConnectionString'
    properties: {
      value: exitcamConnectionString
    }
  } 
  resource appInsightsInstrumentationKeySecret 'secrets' = {
    name: 'appInsightsInstrumentationKey'
    properties: {
      value: appInsightsInstrumentationKey
    }
  } 
  resource maildevHostSecret 'secrets' = {
    name: 'maildevHost'
    properties: {
      value: maildevHost
    }
  } 
}
