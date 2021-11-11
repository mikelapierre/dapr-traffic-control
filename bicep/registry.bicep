param location string
param registryName string

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

output registryServer string = registry.properties.loginServer
output registryUsername string = registry.listCredentials().username
output registryPassword string = registry.listCredentials().passwords[0].value
