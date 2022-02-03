param location string = resourceGroup().location
param environmentName string = 'env-${uniqueString(resourceGroup().id)}'
param storageAccountName string = 'storage${uniqueString(resourceGroup().id)}'
param registryName string = 'registry${uniqueString(resourceGroup().id)}'
param serviceBusNamespaceName string = 'servicebusns-${uniqueString(resourceGroup().id)}'
param eventHubNamespaceName string = 'eventhubns-${uniqueString(resourceGroup().id)}'
param vaultName string = 'vault-${uniqueString(resourceGroup().id)}'
param maildevDnsName string = 'maildev-${uniqueString(resourceGroup().id)}'
param tenantId string = subscription().tenantId
param servicePrincipalId string

module environment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    environmentName: environmentName
    location: location
    vaultName: vaultName
  }
  dependsOn: [
    keyvault
  ] 
}

module storage 'storage.bicep' = {
  name: 'storage-account'
  params: {
    location: location
    storageAccountName: storageAccountName
    vaultName: vaultName
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
  }
  dependsOn: [
    keyvault
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

module keyvault 'keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    tenantId: tenantId
    objectId: servicePrincipalId
    vaultName: vaultName
  }
}

output keyVaultName string = vaultName
