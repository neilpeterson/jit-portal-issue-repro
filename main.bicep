targetScope = 'subscription'

@secure()
param AdminPassword string

param ResourceGroups object
param JitRules object
param VirtualMachineOneParams object
param VirtualMachineTwoParams object

resource ResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: ResourceGroups.ResourceGroupNameUS
  location: ResourceGroups.ResourceGroupLocationUS
}

module Networking './modules/networking.bicep' = {
  scope: ResourceGroup
  name: 'NetworkingUS'
   params: {
     Location: ResourceGroups.ResourceGroupLocationUS
   }
}

module AvalilabilitySet './modules/availability-set.bicep' = {
  scope: ResourceGroup
  name: 'availabilitySetUS'
   params: {
     Name: 'aveastus'
     Location: ResourceGroups.ResourceGroupLocationUS
   }
}

module VirtualMachineOne './modules/virtual-machine.bicep' = {
  scope: ResourceGroup
  name: 'domainControllerUS1'
  params: {
    VMName: VirtualMachineOneParams.VMName
    NicName: VirtualMachineOneParams.VMName
    AdminUserName: VirtualMachineOneParams.AdminUserName
    AdminPassword: AdminPassword
    VirtualMachineSize: VirtualMachineOneParams.VirtualMachineSize
    WindowsOSVersion: VirtualMachineOneParams.WindowsOSVersion
    VirtualNetworkID: Networking.outputs.vnetID
    SubnetName: Networking.outputs.subnet
    AvailabilitySetID: AvalilabilitySet.outputs.AvailabilitySetID
    Location: ResourceGroups.ResourceGroupLocationUS
    IPAddress: VirtualMachineOneParams.PrivateIPAddress
    JitRules: JitRules
  }
}

module VirtualMachineTwo './modules//virtual-machine.bicep' = {
  scope: ResourceGroup
  name: 'domainControllerUS2'
  params: {
    VMName: VirtualMachineTwoParams.VMName
    NicName: VirtualMachineTwoParams.VMName
    AdminUserName: VirtualMachineTwoParams.AdminUserName
    AdminPassword: AdminPassword
    VirtualMachineSize: VirtualMachineOneParams.VirtualMachineSize
    WindowsOSVersion: VirtualMachineOneParams.WindowsOSVersion
    VirtualNetworkID: Networking.outputs.vnetID
    SubnetName: Networking.outputs.subnet
    AvailabilitySetID: AvalilabilitySet.outputs.AvailabilitySetID
    Location: ResourceGroups.ResourceGroupLocationUS
    IPAddress: VirtualMachineTwoParams.PrivateIPAddress
    JitRules: JitRules
  }
  dependsOn: [
    VirtualMachineOne
  ]
}
