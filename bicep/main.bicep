param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'
param registryName string = 'registry${uniqueString(resourceGroup().id)}'
param serviceBusNamespaceName string = 'servicebusns-${uniqueString(resourceGroup().id)}'
param eventHubNamespaceName string = 'eventhubns-${uniqueString(resourceGroup().id)}'
param vaultName string = 'vault-${uniqueString(resourceGroup().id)}'
param maildevDnsName string = 'maildev-${uniqueString(resourceGroup().id)}'
param vnetName string = 'vnet-${uniqueString(resourceGroup().id)}'
param tenantId string = subscription().tenantId
param servicePrincipalId string
param deployInVnet bool

module vnet 'vnet.bicep' = if (deployInVnet) {
  name: 'vnet'
  params: {
    location: location
    vnetName: vnetName
  }
}

module keyvault 'keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    tenantId: tenantId
    objectId: servicePrincipalId
    vaultName: vaultName
    deployInVnet: deployInVnet
    vnetId: deployInVnet ? vnet.outputs.vnetId : ''
    privateEndpointSubnetId: deployInVnet ? vnet.outputs.privateEndpointSubnetId : ''
    containerInstanceSubnetId: deployInVnet ? vnet.outputs.containerInstanceSubnetId : ''
  }
}

module storage 'storage.bicep' = {
  name: 'storage-account'
  params: {
    location: location
    storageAccountName: storageAccountName
    vaultName: vaultName
    deployInVnet: deployInVnet
    vnetId: deployInVnet ? vnet.outputs.vnetId : ''
    privateEndpointSubnetId: deployInVnet ? vnet.outputs.privateEndpointSubnetId : '' 
  }
  dependsOn: [
    keyvault
  ] 
}

module registry 'registry.bicep' = {
  name: 'container-registry'
  params: {
    location: location
    registryName: registryName
    vaultName: vaultName
    deployInVnet: deployInVnet
    vnetId: deployInVnet ? vnet.outputs.vnetId : ''
    privateEndpointSubnetId: deployInVnet ? vnet.outputs.privateEndpointSubnetId : ''    
  }
  dependsOn: [
    keyvault
  ] 
}

module servicebus 'servicebus.bicep' = {
  name: 'servicebus-namespace'
  params: {
    location: location
    serviceBusNamespaceName: serviceBusNamespaceName
    vaultName: vaultName
    deployInVnet: deployInVnet
    vnetId: deployInVnet ? vnet.outputs.vnetId : ''
    privateEndpointSubnetId: deployInVnet ? vnet.outputs.privateEndpointSubnetId : ''       
  }
  dependsOn: [
    keyvault
  ] 
}

module eventhub 'eventhub.bicep' = {
  name: 'eventhub'
  params: {
    location: location    
    eventHubNamespaceName: eventHubNamespaceName
    vaultName: vaultName
    deployInVnet: deployInVnet
    vnetId: deployInVnet ? vnet.outputs.vnetId : ''
    privateEndpointSubnetId: deployInVnet ? vnet.outputs.privateEndpointSubnetId : ''
  }
  dependsOn: [
    keyvault
    servicebus // To prevent the private dns zone to be created simultanously
  ] 
}

module environment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    environmentName: environmentName
    location: location
    vaultName: vaultName    
    storageAccountName: storageAccountName
    eventHubNamespaceName: eventHubNamespaceName
    serviceBusNamespaceName: serviceBusNamespaceName
    smtpHost: maildev.outputs.smtpHost
    deployInVnet: deployInVnet
    appsSubnetId: deployInVnet ? vnet.outputs.appSubnetId : ''
    controlPlaneSubnetId: deployInVnet ? vnet.outputs.controlPlanSubnetId : ''
  }
  dependsOn: [
    keyvault    
    storage
    eventhub
    servicebus
  ] 
}

module maildev 'maildev.bicep' = {
  name: 'maildev'
  params: {
    location: location
    dnsNameLabel: maildevDnsName
    vaultName: vaultName   
  }
  dependsOn: [
    keyvault
  ] 
}

output keyVaultName string = vaultName
