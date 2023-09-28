param environmentName string
param logAnalyticsWorkspaceName string = 'logs-${environmentName}'
param appInsightsName string = 'appins-${environmentName}'
param location string = resourceGroup().location
param vaultName string
param storageAccountName string
param eventHubNamespaceName string
param serviceBusNamespaceName string
param smtpHost string
param deployInVnet bool
param appsSubnetId string = ''
param controlPlaneSubnetId string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: storageAccountName
}

resource eventhubNs 'Microsoft.EventHub/namespaces@2017-04-01' existing = {
  name: eventHubNamespaceName
  resource entrycamHub 'eventhubs' existing = {
    name: 'entrycam'
    resource authRule 'authorizationRules' existing = {
      name: 'Full'
    }    
  }
  resource exitcamHub 'eventhubs' existing = {
    name: 'exitcam'
    resource authRule 'authorizationRules' existing = {
      name: 'Full'
    }     
  }  
}

resource servicebusNs 'Microsoft.ServiceBus/namespaces@2017-04-01' existing = {
  name: serviceBusNamespaceName
  resource topic 'topics' existing = {
    name: 'speedingviolations'
    resource authRule 'authorizationRules' existing = {
      name: 'Full'
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
  }
}

resource environment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: environmentName
  location: location
  properties: {
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    vnetConfiguration: {
      infrastructureSubnetId: deployInVnet ? controlPlaneSubnetId : null
      runtimeSubnetId: deployInVnet ? appsSubnetId : null
      internal: deployInVnet      
    }
  }

  resource pubsub 'daprComponents' = {
    name: 'pubsub'
     properties: {
       componentType: 'pubsub.azure.servicebus'
       version: 'v1'
       secrets: [
        {
          name: 'servicebus-connectionstring'
          value: servicebusNs::topic::authRule.listkeys().primaryConnectionString
        }
       ]
       metadata: [
        {
          name: 'connectionString'
          secretRef: 'servicebus-connectionstring'
        }
        {
          name: 'consumerID'
          value: 'finecollectionservice'
        }
       ]
       scopes: [
        'trafficcontrolservice'
        'finecollectionservice'
       ]
     }
  }

  resource entrycam 'daprComponents' = {
    name: 'entrycam'
     properties: {
       componentType: 'bindings.azure.eventhubs'
       version: 'v1'
       secrets: [
        {
          name: 'entrycam-connectionstring'
          value: eventhubNs::entrycamHub::authRule.listkeys().primaryConnectionString
        } 
        {
          name: 'storageaccount-key'
          value: storageAccount.listKeys().keys[0].value
        }        
       ]
       metadata: [
        {
          name: 'connectionString'
          secretRef: 'entrycam-connectionstring'
        }
        {
          name: 'consumerGroup'
          value: '$Default'
        }
        {
          name: 'storageAccountName'
          value: storageAccountName
        }        
        {
          name: 'storageAccountKey'
          secretRef: 'storageaccount-key'
        }
        {
          name: 'storageContainerName'
          value: 'entrycam-checkpoint'
        }        
       ]
       scopes: [
        'trafficcontrolservice'
       ]
     }
     dependsOn: [
      pubsub
     ]         
  }

  resource exitcam 'daprComponents' = {
    name: 'exitcam'
     properties: {
       componentType: 'bindings.azure.eventhubs'
       version: 'v1'
       secrets: [
        {
          name: 'exitcam-connectionstring'
          value: eventhubNs::exitcamHub::authRule.listkeys().primaryConnectionString
        }
        {
          name: 'storageaccount-key'
          value: storageAccount.listKeys().keys[0].value
        }        
       ]
       metadata: [
        {
          name: 'connectionString'
          secretRef: 'exitcam-connectionstring'
        }
        {
          name: 'consumerGroup'
          value: '$Default'
        }
        {
          name: 'storageAccountName'
          value: storageAccountName
        }        
        {
          name: 'storageAccountKey'
          secretRef: 'storageaccount-key'
        }
        {
          name: 'storageContainerName'
          value: 'exitcam-checkpoint'
        }        
       ]
       scopes: [
        'trafficcontrolservice'
       ]
     }
     dependsOn: [
      entrycam
     ]       
  }

  resource statestore 'daprComponents' = {
    name: 'statestore'
     properties: {
       componentType: 'state.azure.blobstorage'
       version: 'v1'
       secrets: [
        {
          name: 'storageaccount-key'
          value: storageAccount.listKeys().keys[0].value
        }        
       ]
       metadata: [
        {
          name: 'accountName'
          value: storageAccountName
        }        
        {
          name: 'accountKey'
          secretRef: 'storageaccount-key'
        }
        {
          name: 'containerName'
          value: 'dapr-state'
        }        
       ]
       scopes: [
        'trafficcontrolservice'
       ]
     }
     dependsOn: [
      exitcam
     ]     
  }  

  resource sendmail 'daprComponents' = {
    name: 'sendmail'
     properties: {
       componentType: 'bindings.smtp'
       version: 'v1'
       secrets: [
        {
          name: 'smtp-username'
          value: '_username'
        }
        {
          name: 'smtp-password'
          value: '_password'
        }        
       ]
       metadata: [
        {
          name: 'host'
          value: smtpHost
        }
        {
          name: 'port'
          value: '1025'
        }
        {
          name: 'user'
          secretRef: 'smtp-username'
        }
        {
          name: 'password'
          secretRef: 'smtp-password'
        }
        {
          name: 'skipTLSVerify'
          value: 'true'
        }                
       ]
       scopes: [
        'finecollectionservice'
       ]
     }
     dependsOn: [
      statestore
     ]
  }  

}
resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing =  {
  name: vaultName

  resource environmentIdSecret 'secrets' = {
    name: 'environmentId'
    properties: {
      value: environment.id
    }
  }
  resource appInsightsInstrumentationKeySecret 'secrets' = {
    name: 'appInsightsInstrumentationKey'
    properties: {
      value: appInsights.properties.InstrumentationKey
    }
  } 
}
