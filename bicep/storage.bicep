param location string
param storageAccountName string
param vaultName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'    
  }
  kind: 'StorageV2'
  properties: {
    encryption: {
      services: {
        blob: {
          keyType: 'Account'
          enabled: true
        }
        file: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing =  {
  name: vaultName

  resource storageAccountNameSecret 'secrets' = {
    name: 'storageAccountName'
    properties: {
      value: storageAccountName
    }
  } 
  resource storageAccountKeySecret 'secrets' = {
    name: 'storageAccountKey'
    properties: {
      value: storageAccount.listKeys().keys[0].value
    }
  }  
}
