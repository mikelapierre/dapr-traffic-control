param location string
param eventHubNamespaceName string

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

output nsConnectionString string = eventhubNs::authRule.listkeys().primaryConnectionString
output entryCamConnectionString string = eventhubNs::entrycamHub::authRule.listkeys().primaryConnectionString
output exitCamConnectionString string = eventhubNs::exitcamHub::authRule.listkeys().primaryConnectionString
