param AdminUserName string

@secure()
param AdminPassword string
param VirtualMachineSize string
param Location string
param WindowsOSVersion string
param VirtualNetworkID string
param SubnetName string
param NicName string
param VMName string
param IPAddress string
param AvailabilitySetID string
param JitSourceIP string

resource VirtualMachineNSG 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: VMName
  location: Location
  properties: {
    securityRules: [
    ]
  }
}

resource NICVirtualMachine 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: NicName
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: IPAddress
          subnet: {
            id: '${VirtualNetworkID}/subnets/${SubnetName}'
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: VirtualMachineNSG.id
    }
  }
}

resource VirtualMachine 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: VMName
  location: Location
  properties: {
    hardwareProfile: {
      vmSize: VirtualMachineSize
    }
    osProfile: {
      computerName: VMName
      adminUsername: AdminUserName
      adminPassword: AdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: WindowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: []
    }
    licenseType: 'Windows_Server'
    networkProfile: {
      networkInterfaces: [
        {
          id: NICVirtualMachine.id
        }
      ]
    }
    availabilitySet: {
      id: AvailabilitySetID
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource ManagementPortJITPolicy 'Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01' = {
  name: '${Location}/${VMName}'
  kind: 'Basic'
  properties: {
    virtualMachines: [
      {
        id: VirtualMachine.id
        ports: [
          {
            number: 22
            protocol: '*'
            allowedSourceAddressPrefixes: [
              JitSourceIP
            ]
            maxRequestAccessDuration: 'PT3H'
          }
          {
            number: 3389
            protocol: '*'
            allowedSourceAddressPrefixes: [
              JitSourceIP
            ]
            maxRequestAccessDuration: 'PT3H'
          }
          {
            number: 5985
            protocol: '*'
            allowedSourceAddressPrefixes: [
              JitSourceIP
            ]
            maxRequestAccessDuration: 'PT3H'
          }
          {
            number: 5986
            protocol: '*'
            allowedSourceAddressPrefixes: [
              JitSourceIP
            ]
            maxRequestAccessDuration: 'PT3H'
          }
        ]
      }
    ]
  }
}
