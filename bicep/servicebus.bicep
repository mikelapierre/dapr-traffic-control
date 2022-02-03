param location string
param serviceBusNamespaceName string
param vaultName string
param deployInVnet bool
param vnetId string = ''
param privateEndpointSubnetId string = ''

resource servicebusNs 'Microsoft.ServiceBus/namespaces@2017-04-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: deployInVnet ? 'Premium' : 'Standard'
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

  resource networkRules 'networkRuleSets' = {
    name: 'default'
    properties: {
      defaultAction: 'Deny'
    }
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: vaultName

  resource serviceBusConnectionStringSecret 'secrets' = {
    name: 'serviceBusConnectionString'
    properties: {
      value: servicebusNs::topic::authRule.listkeys().primaryConnectionString
    }
  }
}

resource privatedns 'Microsoft.Network/privateDnsZones@2020-06-01' = if (deployInVnet) {
  name: 'privatelink.servicebus.windows.net'
  location: 'global'
  resource vnetLink 'virtualNetworkLinks' = {
    name: 'servicebus-link'
    location: 'global'
    properties: {
      virtualNetwork: {
        id: vnetId
      }
      registrationEnabled: false
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = if (deployInVnet) {
  name: '${serviceBusNamespaceName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'namespace'
        properties: {
          groupIds: [
            'namespace'
          ]
          privateLinkServiceId: servicebusNs.id
        }
      }
    ]
  }
  resource privatednsGroup 'privateDnsZoneGroups' = {
    name: 'namespace'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'namespace'
          properties: {
            privateDnsZoneId: privatedns.id
          }
        }
      ]
    }
  }  
}
