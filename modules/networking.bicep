param Location string

param BastionHost object = {
  name: 'AzureBastionHost'
  publicIPAddressName: 'pip-bastion'
  subnetName: 'AzureBastionSubnet'
  nsgName: 'nsg-spoke-bastion'
  subnetPrefix: '10.0.1.0/29'
}

param SpokeNetwork object = {
  name: 'vnet-spoke'
  addressPrefix: '10.0.0.0/20'
}

param ResourceSubnet object = {
  subnetName: 'ResourceSubnet'
  nsgName: 'nsg-spoke-resources'
  subnetPrefix: '10.0.2.0/24'
}

resource NSGVirtualMachines 'Microsoft.Network/networkSecurityGroups@2020-08-01' = {
  name: 'nsgVirtualMachines'
  location: Location
  properties: {
    securityRules: [
      {
        name: 'bastion-in-vnet'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: BastionHost.subnetPrefix
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource VirtualNetworkSpoke 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: SpokeNetwork.name
  location: Location
  properties: {
    addressSpace: {
      addressPrefixes: [
        SpokeNetwork.addressPrefix
      ]
    }
    subnets: [
      {
        name: BastionHost.subnetName
        properties: {
          addressPrefix: BastionHost.subnetPrefix
          networkSecurityGroup: {
            id: NetworkSecurityGroupBastion.id
          }
        }
      }
      {
        name: ResourceSubnet.subnetName
        properties: {
          addressPrefix: ResourceSubnet.subnetPrefix
          networkSecurityGroup: {
            id: NSGVirtualMachines.id
          }
        }
      }
    ]
  }
}

resource PublicIPBastion 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'bastionpip'
  location: Location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource NetworkSecurityGroupBastion 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: 'nsgbastion'
  location: Location
  properties: {
    securityRules: [
      {
        name: 'bastion-in-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'bastion-control-in-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'bastion-in-host'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'bastion-vnet-out-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'bastion-azure-out-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'bastion-out-host'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'bastion-out-deny'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource Bastion 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: 'bastionhost'
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconf'
        properties: {
          subnet: {
            id: '${VirtualNetworkSpoke.id}/subnets/${BastionHost.subnetName}'
          }
          publicIPAddress: {
            id: PublicIPBastion.id
          }
        }
      }
    ]
  }
}

output vnetID string = VirtualNetworkSpoke.id
output subnet string = ResourceSubnet.subnetName
