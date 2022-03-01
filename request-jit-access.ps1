$MyResource = Get-AzResource -Id /subscriptions/3762d87c-ddb8-425f-b2fc-29e5e859edaf/resourceGroups/test-005/providers/Microsoft.Compute/virtualMachines/JIT-VM-002
$JitPolicy = (@{
        id    = $MyResource.ResourceId; 
        ports = (@{
                number                     = 3389
                endTimeUtc                 = Get-Date (Get-Date -AsUTC).AddHours(1) -Format O
                allowedSourceAddressPrefix = @('73.225.95.26') 
            })
    })
$ActivationVM = @($JitPolicy)
Start-AzJitNetworkAccessPolicy -ResourceGroupName $($MyResource.ResourceGroupName) -Location $MyResource.Location -Name $MyResource.Name -VirtualMachine $ActivationVM