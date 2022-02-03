param location string
param vaultName string
param tenantId string
param objectId string
param deployInVnet bool
param vnetId string = ''
param privateEndpointSubnetId string = ''
param containerInstanceSubnetId string = ''

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
    networkAcls: {
      defaultAction: 'Allow' // Allow to be able to deploy from GitHub managed runners
    }
    enableSoftDelete: false
  }

  resource resourceGroupSecret 'secrets' = {
    name: 'resourceGroup'
    properties: {
      value: resourceGroup().name
    }
  }

  resource containerInstanceSubnetIdSecret 'secrets' = {
    name: 'containerInstanceSubnetId'
    properties: {
      value: containerInstanceSubnetId
    }
  }  
}

resource privatedns 'Microsoft.Network/privateDnsZones@2020-06-01' = if (deployInVnet) {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'

  resource vnetLink 'virtualNetworkLinks' = {
    name: 'vault-link'
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
  name: '${vaultName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'vault'
        properties: {
          groupIds: [
            'vault'
          ]
          privateLinkServiceId: keyvault.id
        }
      }
    ]
  }
  resource privatednsGroup 'privateDnsZoneGroups' = {
    name: 'vault'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'vault'
          properties: {
            privateDnsZoneId: privatedns.id
          }
        }
      ]
    }
  }
}
