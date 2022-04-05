param environmentName string
param location string = resourceGroup().location
param vaultName string
param deployInVnet bool
param appsSubnetId string = ''
param controlPlaneSubnetId string = ''

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: vaultName
}

module environment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    environmentName: environmentName
    location: location
    vaultName: vaultName    
    storageAccountName: kv.getSecret('storageAccountName')
    storageAccountKey: kv.getSecret('storageAccountKey')
    entrycamConnectionString: kv.getSecret('entrycamConnectionString')
    exitcamConnectionString: kv.getSecret('entrycamConnectionString')
    serviceBusConnectionString: kv.getSecret('serviceBusConnectionString')
    smtpHost: kv.getSecret('maildevHost')
    deployInVnet: deployInVnet
    appsSubnetId: appsSubnetId
    controlPlaneSubnetId: controlPlaneSubnetId
  }
}
