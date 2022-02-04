param location string
param registryName string
param vaultName string
param deployInVnet bool
param vnetId string = ''
param privateEndpointSubnetId string = ''

resource registry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: registryName
  location: location
  sku: {
    name: deployInVnet ? 'Premium' : 'Basic'
  }
  properties: {
    adminUserEnabled: true
    networkRuleSet: deployInVnet ? {
      defaultAction: 'Allow' // Allow to be able to deploy from GitHub managed runners
    } : null
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: vaultName

  resource registryServerSecret 'secrets' = {
    name: 'registryServer'
    properties: {
      value: registry.properties.loginServer
    }
  }
  resource registryUsernameSecret 'secrets' = {
    name: 'registryUsername'
    properties: {
      value: registry.listCredentials().username
    }
  }
  resource registryPasswordSecret 'secrets' = {
    name: 'registryPassword'
    properties: {
      value: registry.listCredentials().passwords[0].value
    }
  }
}

resource privatedns 'Microsoft.Network/privateDnsZones@2020-06-01' = if (deployInVnet) {
  name: 'privatelink.azurecr.io'
  location: 'global'
  resource vnetLink 'virtualNetworkLinks' = {
    name: 'registry-link'
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
  name: '${registryName}-pe'
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'registry'
        properties: {
          groupIds: [
            'registry'
          ]
          privateLinkServiceId: registry.id
        }
      }
    ]
  }
  resource privatednsGroup 'privateDnsZoneGroups' = {
    name: 'registry'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'registry'
          properties: {
            privateDnsZoneId: privatedns.id
          }
        }
      ]
    }
  }  
}
