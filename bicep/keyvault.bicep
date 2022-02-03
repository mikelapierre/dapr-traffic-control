param location string
param vaultName string
param tenantId string
param objectId string

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

  resource resourceGroupSecret 'secrets' = {
    name: 'resourceGroup'
    properties: {
      value: resourceGroup().name
    }
  }
}
