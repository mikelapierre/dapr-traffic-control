param location string
param dnsNameLabel string
param vaultName string

resource maildev 'Microsoft.ContainerInstance/containerGroups@2021-07-01' = {
  name: 'maildev'
  location: location
  properties: {
    containers: [
      {
        name: 'maildev'
        properties: {
          image: 'maildev/maildev'
          command:  [
            '/usr/src/app/bin/maildev'
            '-s'
            '1025'
            '-w'
            '1080'
          ]
          ports: [
            {
              port: 1025
              protocol: 'TCP'
            }
            {
              port: 1080
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 1
            }
          }
        }
      }
    ]
    osType: 'Linux'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 1025
          protocol: 'TCP'
        }
        {
          port: 1080
          protocol: 'TCP'
        }
      ]
      dnsNameLabel: dnsNameLabel
    }
  }
}

resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' existing =  {
  name: vaultName

  resource maildevHostSecret 'secrets' = {
    name: 'maildevHost'
    properties: {
      value: maildev.properties.ipAddress.fqdn
    }
  } 
}

output smtpHost string = maildev.properties.ipAddress.fqdn
