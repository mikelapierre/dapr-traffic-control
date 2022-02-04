param location string
param eventHubNamespaceName string
param vaultName string
param deployInVnet bool
param vnetId string = ''
param privateEndpointSubnetId string = ''

resource eventhubNs 'Microsoft.EventHub/namespaces@2017-04-01' = {
  name: eventHubNamespaceName
  location: location
  sku: {
    name: deployInVnet ? 'Standard' : 'Basic'
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

  resource networkRules 'networkRuleSets' = if (deployInVnet) {
    name: 'default'
    properties: {
      defaultAction: 'Deny'
      ipRules: [
         {
            action: 'Allow'
            ipMask: '0.0.0.0/32'
         }
      ]
    }
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
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
  name: '${eventHubNamespaceName}-pe'
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
          privateLinkServiceId: eventhubNs.id
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
