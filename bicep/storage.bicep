param location string
param storageAccountName string
param vaultName string
param deployInVnet bool
param vnetId string = ''
param privateEndpointSubnetId string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          keyType: 'Account'
          enabled: true
        }
        file: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    networkAcls: {
      defaultAction: 'Deny'
    }
    accessTier: 'Hot'
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: vaultName

  resource storageAccountNameSecret 'secrets' = {
    name: 'storageAccountName'
    properties: {
      value: storageAccountName
    }
  }
  resource storageAccountKeySecret 'secrets' = {
    name: 'storageAccountKey'
    properties: {
      value: storageAccount.listKeys().keys[0].value
    }
  }
}

resource privatedns 'Microsoft.Network/privateDnsZones@2020-06-01' = if (deployInVnet) {
  name: 'privatelink.blob.core.windows.net'
  location: 'global'
  resource vnetLink 'virtualNetworkLinks' = {
    name: 'storage-blob-link'
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
  name: '${storageAccountName}-blob-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'blob'
        properties: {
          groupIds: [
            'blob'
          ]
          privateLinkServiceId: storageAccount.id
        }
      }
    ]
  }
  resource privatednsGroup 'privateDnsZoneGroups' = {
    name: 'blob'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'blob'
          properties: {
            privateDnsZoneId: privatedns.id
          }
        }
      ]
    }
  }
}
