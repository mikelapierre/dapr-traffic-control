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
  }
}

module storage 'storage.bicep' = {
  name: 'storage-account'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

module registry 'registry.bicep' = {
  name: 'container-registry'
  params: {
    location: location
    registryName: registryName
  }
}

module servicebus 'servicebus.bicep' = {
  name: 'servicebus-namespace'
  params: {
    location: location
    serviceBusNamespaceName: serviceBusNamespaceName
  }
}

module eventhub 'eventhub.bicep' = {
  name: 'eventhub'
  params: {
    location: location    
    eventHubNamespaceName: eventHubNamespaceName
  }
}

module maildev 'maildev.bicep' = {
  name: 'maildev'
  params: {
    location: location
    dnsNameLabel: maildevDnsName
  }
}

module kevault 'keyvault.bicep' = {
  name: 'keyvault'
  params: {
    location: location
    tenantId: tenantId
    objectId: servicePrincipalId
    vaultName: vaultName
    registryServer: registry.outputs.registryServer
    registryUsername: registry.outputs.registryUsername
    registryPassword: registry.outputs.registryPassword
    environmentId: environment.outputs.environmentId
    serviceBusConnectionString: servicebus.outputs.connectionString
    storageAccountName: storageAccountName
    storageAccountKey: storage.outputs.storageAccountKey
    eventHubNsConnectionString: eventhub.outputs.nsConnectionString
    entrycamConnectionString: eventhub.outputs.entryCamConnectionString
    exitcamConnectionString: eventhub.outputs.exitCamConnectionString
    appInsightsInstrumentationKey: environment.outputs.appInsightsInstrumentationKey
    maildevHost: maildev.outputs.maildevHost
  }
}

output keyVaultName string = vaultName
