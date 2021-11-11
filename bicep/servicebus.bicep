param location string
param serviceBusNamespaceName string

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

output connectionString string = servicebusNs::topic::authRule.listkeys().primaryConnectionString
