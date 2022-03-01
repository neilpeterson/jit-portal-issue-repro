param Location string
param Name string

resource AvailabilitySet 'Microsoft.Compute/availabilitySets@2020-12-01' = {
  name: Name
  location: Location
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: 2
    platformUpdateDomainCount: 2
  }
}

output AvailabilitySetID string = AvailabilitySet.id
