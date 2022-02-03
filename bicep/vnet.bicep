param location string
param vnetName string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
     addressSpace: {
        addressPrefixes: [
          '10.10.0.0/16'
        ]      
     }
     subnets: [
      {
        name: 'container-apps'
        properties: {
           addressPrefix: '10.10.0.0/21'
        }
      }       
      {
        name: 'container-controlplane'
        properties: {
          addressPrefix: '10.10.8.0/21'
        }
      }
      {
        name: 'private-endpoints'
        properties: {
            addressPrefix: '10.10.16.0/28'
            privateEndpointNetworkPolicies: 'Disabled'
        }
      }        
     ]
  }
}

output vnetId string = vnet.id
output appSubnetId string = vnet.properties.subnets[0].id
output controlPlanSubnetId string = vnet.properties.subnets[1].id
output privateEndpointSubnetId string = vnet.properties.subnets[2].id
