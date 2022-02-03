param location string
param registryName string
param vaultName string

resource registry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: registryName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing =  {
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