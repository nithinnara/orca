<#

156 Determines if SafeLinks URL tracing is enabled on the default policy for Office apps or in a Policy, does not however check that there is a rule enforcing this policy.

#>

using module "..\ORCA.psm1"

class ORCA156 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA156()
    {
        $this.Control=156
        $this.Services=[ORCAService]::MDO
        $this.Area="Microsoft Defender for Office 365 Policies"
        $this.Name="Safe Links Tracking"
        $this.PassText="Safe Links Policies are tracking when user clicks on safe links"
        $this.FailRecommendation="Enable tracking of user clicks in Safe Links Policies"
        $this.Importance="When these options are configured, click data for URLs in Word, Excel, PowerPoint, Visio documents and in emails is stored by Safe Links. This information can help dealing with phishing, suspicious email messages and URLs."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Policy"
        $this.ItemName="Setting"
        $this.DataType="Current Value"
        $this.ChiValue=[ORCACHI]::High
        $this.Links= @{
            "Security & Compliance Center - Safe links"="https://security.microsoft.com/safelinksv2"
            "Recommended settings for EOP and Microsoft Defender for Office 365"="https://aka.ms/orca-atpp-docs-7"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {   
       
        ForEach($Policy in $Config["SafeLinksPolicy"]) 
        {
            $IsPolicyDisabled = !$Config["PolicyStates"][$Policy.Guid.ToString()].Applies
            $TrackUserClicks = $($Policy.TrackClicks)

            $policyname = $Config["PolicyStates"][$Policy.Guid.ToString()].Name

            $ConfigObject = [ORCACheckConfig]::new()
            $ConfigObject.Object=$policyname
            $ConfigObject.ConfigItem="TrackClicks"
            $ConfigObject.ConfigData=$TrackUserClicks
            $ConfigObject.ConfigReadonly=$Policy.IsPreset
            $ConfigObject.ConfigDisabled=$IsPolicyDisabled
            $ConfigObject.ConfigPolicyGuid=$Policy.Guid.ToString()

            # Determine if MDO link tracking is on for this safelinks policy
            If($TrackUserClicks -eq $True)
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")
            } 
            else 
            {
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")
            }

            # Add config to check
            $this.AddConfig($ConfigObject)
            
        }        

    }

}