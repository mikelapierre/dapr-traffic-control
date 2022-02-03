param location string
param serviceBusNamespaceName string
param vaultName string

resource servicebusNs 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  
  resource topic 'topics' = {
    name: 'speedingviolations'
  
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

    resource subscription 'subscriptions' = {
      name: 'finecollectionservice'
    }    
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing =  {
  name: vaultName

  resource serviceBusConnectionStringSecret 'secrets' = {
    name: 'serviceBusConnectionString'
    properties: {
      value: servicebusNs::topic::authRule.listkeys().primaryConnectionString
    }
  }  
}
