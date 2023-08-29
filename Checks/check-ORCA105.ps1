using module "..\ORCA.psm1"

class ORCA105 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA105()
    {
        $this.Control="ORCA-105"
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Safe Links Synchronous URL detonation"
        $this.PassText="Safe Links Synchronous URL detonation is enabled"
        $this.FailRecommendation="Enable Safe Links Synchronous URL detonation"
        $this.Importance="When the 'Wait for URL scanning to complete before delivering the message' option is configured, messages that contain URLs to be scanned will be held until the URLs finish scanning and are confirmed to be safe before the messages are delivered."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::Medium
        $this.Links= @{
            "Security & Compliance Center - Safe links"="https://security.microsoft.com/safelinksv2"
            "Set up Microsoft Defender for Office 365 Safe Links policies"="https://aka.ms/orca-atpp-docs-10"
            "Recommended settings for EOP and Office 365 Microsoft Defender for Office 365 security"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        $EnabledPolicyExists = $False

        ForEach($Policy in ($Config["SafeLinksPolicy"] )) 
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies

            if(!$IsPolicyDisabled)
            {
                $EnabledPolicyExists = $True
            }

            $DeliverMessageAfterScan =$($Policy.DeliverMessageAfterScan)
            $ScanUrls = $($Policy.ScanUrls)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            <#
            
            DeliverMessageAfterScan
            
            #>

                # Check objects
                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.Object= $policyname
                $ConfigObject.ConfigItem="DeliverMessageAfterScan"
                $ConfigObject.ConfigData=$DeliverMessageAfterScan
                $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                $ConfigObject.ConfigReadonly=$Policy.IsPreset
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                # Determine if DeliverMessageAfterScan is on for this safelinks policy
                If($DeliverMessageAfterScan -eq $true) 
                {
                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")

                    if(!$IsPolicyDisabled)
                    {
                        $AnyEnabled_DeliverMessageAfterScan = $True
                    }
                }
                Else 
                {
                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
                }

                # Add config to check
                $this.AddConfig($ConfigObject)

            <#
            
            ScanUrls
            
            #>

                # Check objects
                $ConfigObject = [ORCACheckConfig]::new()
                $ConfigObject.Object= $policyname
                $ConfigObject.ConfigItem="ScanUrls"
                $ConfigObject.ConfigData=$ScanUrls
                $ConfigObject.ConfigDisabled=$IsPolicyDisabled
                $ConfigObject.ConfigReadonly=$Policy.IsPreset
                $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

                If($ScanUrls -eq $true)
                {
                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")

                    if(!$IsPolicyDisabled)
                    {
                        $AnyEnabled_ScanUrls = $True
                    }
                }
                Else 
                {
                    $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
                }

                # Add config to check
                $this.AddConfig($ConfigObject)

        }

        If(!$EnabledPolicyExists)
        {

            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object="All enabled policies"
            $ConfigObject.ConfigItem="DeliverMessageAfterScan"
            $ConfigObject.ConfigData="False"
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            
            # Add config to check
            $this.AddConfig($ConfigObject)

            # Check objects
            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object="All enabled policies"
            $ConfigObject.ConfigItem="ScanUrls"
            $ConfigObject.ConfigData="False"
            $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            
            # Add config to check
            $this.AddConfig($ConfigObject)
        }

    }

}

