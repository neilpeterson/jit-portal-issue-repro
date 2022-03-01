$JitPolicy = (@{
    id="/subscriptions/3762d87c-ddb8-425f-b2fc-29e5e859edaf/resourceGroups/test-005/providers/Microsoft.Compute/virtualMachines/JIT-VM-001";
    ports=(@{
         number=22;
         protocol="*";
         allowedSourceAddressPrefix=@("*");
         maxRequestAccessDuration="PT3H"},
         @{
         number=3389;
         protocol="*";
         allowedSourceAddressPrefix=@("*");
         maxRequestAccessDuration="PT3H"})})

$JitPolicyArr=@($JitPolicy)
Set-AzJitNetworkAccessPolicy -Kind "Basic" -Location "eastus" -Name "JIT-VM-001" -ResourceGroupName "test-005" -VirtualMachine $JitPolicyArr