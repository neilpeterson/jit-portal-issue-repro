param AdminUserName string
@secure()
param AdminPassword string
param VirtualMacineNameOne string = 'JIT-VM-001'
param VirtualMacineNameTwo string = 'JIT-VM-002'
param JitSourceIp string = '73.225.95.26'
param Location string = resourceGroup().location

module Networking './modules/networking.bicep' = {
  name: 'NetworkingUS'
   params: {
     Location: Location
   }
}

module AvalilabilitySet './modules/availability-set.bicep' = {
  name: 'availabilitySetUS'
   params: {
     Name: 'aveastus'
     Location: Location
   }
}

module VirtualMachineOne './modules/virtual-machine.bicep' = {
  name: 'domainControllerUS1'
  params: {
    VMName: VirtualMacineNameOne
    NicName: VirtualMacineNameOne
    AdminUserName: AdminUserName
    AdminPassword: AdminPassword
    VirtualMachineSize: 'Standard_DS2_v2'
    WindowsOSVersion: '2022-datacenter'
    VirtualNetworkID: Networking.outputs.vnetID
    SubnetName: Networking.outputs.subnet
    AvailabilitySetID: AvalilabilitySet.outputs.AvailabilitySetID
    Location: Location
    IPAddress: '10.0.2.4'
    JitSourceIP: JitSourceIp
  }
}

module VirtualMachineTwo './modules//virtual-machine.bicep' = {
  name: 'domainControllerUS2'
  params: {
    VMName: VirtualMacineNameTwo
    NicName: VirtualMacineNameTwo
    AdminUserName: AdminUserName
    AdminPassword: AdminPassword
    VirtualMachineSize: 'Standard_DS2_v2'
    WindowsOSVersion: '2022-datacenter'
    VirtualNetworkID: Networking.outputs.vnetID
    SubnetName: Networking.outputs.subnet
    AvailabilitySetID: AvalilabilitySet.outputs.AvailabilitySetID
    Location: Location
    IPAddress: '10.0.2.5'
    JitSourceIP: JitSourceIp
  }
  dependsOn: [
    VirtualMachineOne
  ]
}
