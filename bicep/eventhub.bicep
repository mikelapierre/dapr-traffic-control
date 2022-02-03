param location string
param eventHubNamespaceName string
param vaultName string

resource eventhubNs 'Microsoft.EventHub/namespaces@2017-04-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: 'Basic'
  }
  resource authRule 'authorizationRules'= {
    name: 'Full'
    properties: {
      rights:  [
         'Listen'
         'Manage'
         'Send'
      ]
    }
  }
  
  resource entrycamHub 'eventhubs' = {
    name: 'entrycam'
    properties: {
      messageRetentionInDays: 1
    }
    resource authRule 'authorizationRules' = {
      name: 'Full'
      properties: {
        rights: [
          'Listen'
          'Manage'
          'Send'
        ]
      }
    }
  }
  
  resource exitcamHub 'eventhubs' = {
    name: 'exitcam'
    properties: {
      messageRetentionInDays: 1
    }
    resource authRule 'authorizationRules' = {
      name: 'Full'
      properties: {
        rights: [
          'Listen'
          'Manage'
          'Send'
        ]
      }
    }    
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing =  {
  name: vaultName

  resource eventHubNsConnectionStringSecret 'secrets' = {
    name: 'eventHubNsConnectionString'
    properties: {
      value: eventhubNs::authRule.listkeys().primaryConnectionString
    }
  } 
  resource entrycamConnectionStringSecret 'secrets' = {
    name: 'entrycamConnectionString'
    properties: {
      value: eventhubNs::entrycamHub::authRule.listkeys().primaryConnectionString
    }
  } 
  resource exitcamConnectionStringSecret 'secrets' = {
    name: 'exitcamConnectionString'
    properties: {
      value: eventhubNs::exitcamHub::authRule.listkeys().primaryConnectionString
    }
  } 
}
