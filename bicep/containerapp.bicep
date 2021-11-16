param containerAppName string
param location string = resourceGroup().location
param environmentId string
param containerImage string
param containerPort int
param containerRegistry string
param containerRegistryUsername string
param env array = []
param daprComponents array = []
param minReplicas int = 0
param maxReplicas int = 5
param secrets array = []
param revisionSuffix string
param scaleRules array = []
param containerRegistryPassswordSecret string
@allowed([
  'multiple'
  'single'
])
param revisionMode string = 'multiple'

var cpu = json('0.25')
var memory = '0.5Gi'

resource containerApp 'Microsoft.Web/containerApps@2021-03-01' = {
  name: containerAppName
  kind: 'containerapp'
  location: location
  properties: {
    kubeEnvironmentId: environmentId
    configuration: {
      activeRevisionsMode: revisionMode
      secrets: secrets
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: containerRegistryPassswordSecret
        }
      ]
      //ingress: null
    }
    template: {
      revisionSuffix: revisionSuffix
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
          resources: {
            cpu: cpu
            memory: memory
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: scaleRules
      }
      dapr: {
        enabled: true
        appPort: containerPort
        appId: containerAppName
        components: daprComponents
      }
    }
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
