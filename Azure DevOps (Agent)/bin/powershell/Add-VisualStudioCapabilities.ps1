[CmdletBinding()]
param()

function Add-TestCapability {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        $ShellPath,

        [Parameter(Mandatory = $true)]
        [ref]$Value)

    $directory = [System.IO.Path]::Combine($ShellPath, 'Common7\IDE\CommonExtensions\Microsoft\TestWindow')
    if (!(Test-Container -LiteralPath $directory)) {
        return
    }

    [string]$file = [System.IO.Path]::Combine($directory, 'vstest.console.exe')
    if (!(Test-Leaf -LiteralPath $file)) {
        return
    }

    Write-Capability -Name $Name -Value $directory
    $Value.Value = $directory
}

# Define the key names.
$keyName10 = 'Software\Microsoft\VisualStudio\10.0'
$keyName11 = 'Software\Microsoft\VisualStudio\11.0'
$keyName12 = 'Software\Microsoft\VisualStudio\12.0'
$keyName14 = 'Software\Microsoft\VisualStudio\14.0'
$keyName15 = 'Software\Microsoft\VisualStudio\15.0'
$keyName16 = 'Software\Microsoft\VisualStudio\16.0'

# Add the capabilities.
$latestVS = $null
$latestIde = $null
$latestTest = $null
$null = Add-CapabilityFromRegistry -Name 'VisualStudio_10.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName10 -ValueName 'ShellFolder' -Value ([ref]$latestVS)
$null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_10.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName10 -ValueName 'InstallDir' -Value ([ref]$latestIde)
$null = Add-CapabilityFromRegistry -Name 'VisualStudio_11.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName11 -ValueName 'ShellFolder' -Value ([ref]$latestVS)
$null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_11.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName11 -ValueName 'InstallDir' -Value ([ref]$latestIde)
if ((Add-CapabilityFromRegistry -Name 'VisualStudio_12.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName12 -ValueName 'ShellFolder' -Value ([ref]$latestVS))) {
    $null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_12.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName12 -ValueName 'InstallDir' -Value ([ref]$latestIde)
    Add-TestCapability -Name 'VSTest_12.0' -ShellPath $latestVS -Value ([ref]$latestTest)
}

if ((Add-CapabilityFromRegistry -Name 'VisualStudio_14.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName14 -ValueName 'ShellFolder' -Value ([ref]$latestVS))) {
    $null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_14.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName14 -ValueName 'InstallDir' -Value ([ref]$latestIde)
    Add-TestCapability -Name 'VSTest_14.0' -ShellPath $latestVS -Value ([ref]$latestTest)
}

$vs15 = Get-VisualStudio -MajorVersion 15
if ($vs15 -and $vs15.installationPath) {
    # Add VisualStudio_15.0.
    # End with "\" for consistency with old ShellFolder values.
    $shellFolder15 = $vs15.installationPath.TrimEnd('\'[0]) + "\"
    Write-Capability -Name 'VisualStudio_15.0' -Value $shellFolder15
    $latestVS = $shellFolder15

    # Add VisualStudio_IDE_15.0.
    # End with "\" for consistency with old InstallDir values.
    $installDir15 = ([System.IO.Path]::Combine($shellFolder15, 'Common7', 'IDE')) + '\'
    if ((Test-Container -LiteralPath $installDir15)) {
        Write-Capability -Name 'VisualStudio_IDE_15.0' -Value $installDir15
        $latestIde = $installDir15
    }

    # Add VSTest_15.0.
    $testWindowDir15 = [System.IO.Path]::Combine($installDir15, 'CommonExtensions\Microsoft\TestWindow')
    $vstestConsole15 = [System.IO.Path]::Combine($testWindowDir15, 'vstest.console.exe')
    if ((Test-Leaf -LiteralPath $vstestConsole15)) {
        Write-Capability -Name 'VSTest_15.0' -Value $testWindowDir15
        $latestTest = $testWindowDir15
    }
} else {
    if ((Add-CapabilityFromRegistry -Name 'VisualStudio_15.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName15 -ValueName 'ShellFolder' -Value ([ref]$latestVS))) {
        $null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_15.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName15 -ValueName 'InstallDir' -Value ([ref]$latestIde)
        Add-TestCapability -Name 'VSTest_15.0' -ShellPath $latestVS -Value ([ref]$latestTest)
    }
}

$vs16 = Get-VisualStudio -MajorVersion 16
if ($vs16 -and $vs16.installationPath) {
    # Add VisualStudio_16.0.
    # End with "\" for consistency with old ShellFolder values.
    $shellFolder16 = $vs16.installationPath.TrimEnd('\'[0]) + "\"
    Write-Capability -Name 'VisualStudio_16.0' -Value $shellFolder16
    $latestVS = $shellFolder16

    # Add VisualStudio_IDE_16.0.
    # End with "\" for consistency with old InstallDir values.
    $installDir16 = ([System.IO.Path]::Combine($shellFolder16, 'Common7', 'IDE')) + '\'
    if ((Test-Container -LiteralPath $installDir16)) {
        Write-Capability -Name 'VisualStudio_IDE_16.0' -Value $installDir16
        $latestIde = $installDir16
    }

    # Add VSTest_16.0.
    $testWindowDir16 = [System.IO.Path]::Combine($installDir16, 'CommonExtensions\Microsoft\TestWindow')
    $vstestConsole16 = [System.IO.Path]::Combine($testWindowDir16, 'vstest.console.exe')
    if ((Test-Leaf -LiteralPath $vstestConsole16)) {
        Write-Capability -Name 'VSTest_16.0' -Value $testWindowDir16
        $latestTest = $testWindowDir16
    }
} else {
    if ((Add-CapabilityFromRegistry -Name 'VisualStudio_16.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName16 -ValueName 'ShellFolder' -Value ([ref]$latestVS))) {
        $null = Add-CapabilityFromRegistry -Name 'VisualStudio_IDE_16.0' -Hive 'LocalMachine' -View 'Registry32' -KeyName $keyName16 -ValueName 'InstallDir' -Value ([ref]$latestIde)
        Add-TestCapability -Name 'VSTest_16.0' -ShellPath $latestVS -Value ([ref]$latestTest)
    }
}

if ($latestVS) {
    Write-Capability -Name 'VisualStudio' -Value $latestVS
}

if ($latestIde) {
    Write-Capability -Name 'VisualStudio_IDE' -Value $latestIde
}

if ($latestTest) {
    Write-Capability -Name 'VSTest' -Value $latestTest
}

# SIG # Begin signature block
# MIIjnwYJKoZIhvcNAQcCoIIjkDCCI4wCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA/cDr0Z2ZRUTOH
# +IPopWymnQVZJF3Nnq8x7rQAZHiGP6CCDYEwggX/MIID56ADAgECAhMzAAAB32vw
# LpKnSrTQAAAAAAHfMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjAxMjE1MjEzMTQ1WhcNMjExMjAyMjEzMTQ1WjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQC2uxlZEACjqfHkuFyoCwfL25ofI9DZWKt4wEj3JBQ48GPt1UsDv834CcoUUPMn
# s/6CtPoaQ4Thy/kbOOg/zJAnrJeiMQqRe2Lsdb/NSI2gXXX9lad1/yPUDOXo4GNw
# PjXq1JZi+HZV91bUr6ZjzePj1g+bepsqd/HC1XScj0fT3aAxLRykJSzExEBmU9eS
# yuOwUuq+CriudQtWGMdJU650v/KmzfM46Y6lo/MCnnpvz3zEL7PMdUdwqj/nYhGG
# 3UVILxX7tAdMbz7LN+6WOIpT1A41rwaoOVnv+8Ua94HwhjZmu1S73yeV7RZZNxoh
# EegJi9YYssXa7UZUUkCCA+KnAgMBAAGjggF+MIIBejAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQUOPbML8IdkNGtCfMmVPtvI6VZ8+Mw
# UAYDVR0RBEkwR6RFMEMxKTAnBgNVBAsTIE1pY3Jvc29mdCBPcGVyYXRpb25zIFB1
# ZXJ0byBSaWNvMRYwFAYDVQQFEw0yMzAwMTIrNDYzMDA5MB8GA1UdIwQYMBaAFEhu
# ZOVQBdOCqhc3NyK1bajKdQKVMFQGA1UdHwRNMEswSaBHoEWGQ2h0dHA6Ly93d3cu
# bWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY0NvZFNpZ1BDQTIwMTFfMjAxMS0w
# Ny0wOC5jcmwwYQYIKwYBBQUHAQEEVTBTMFEGCCsGAQUFBzAChkVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY0NvZFNpZ1BDQTIwMTFfMjAx
# MS0wNy0wOC5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG9w0BAQsFAAOCAgEAnnqH
# tDyYUFaVAkvAK0eqq6nhoL95SZQu3RnpZ7tdQ89QR3++7A+4hrr7V4xxmkB5BObS
# 0YK+MALE02atjwWgPdpYQ68WdLGroJZHkbZdgERG+7tETFl3aKF4KpoSaGOskZXp
# TPnCaMo2PXoAMVMGpsQEQswimZq3IQ3nRQfBlJ0PoMMcN/+Pks8ZTL1BoPYsJpok
# t6cql59q6CypZYIwgyJ892HpttybHKg1ZtQLUlSXccRMlugPgEcNZJagPEgPYni4
# b11snjRAgf0dyQ0zI9aLXqTxWUU5pCIFiPT0b2wsxzRqCtyGqpkGM8P9GazO8eao
# mVItCYBcJSByBx/pS0cSYwBBHAZxJODUqxSXoSGDvmTfqUJXntnWkL4okok1FiCD
# Z4jpyXOQunb6egIXvkgQ7jb2uO26Ow0m8RwleDvhOMrnHsupiOPbozKroSa6paFt
# VSh89abUSooR8QdZciemmoFhcWkEwFg4spzvYNP4nIs193261WyTaRMZoceGun7G
# CT2Rl653uUj+F+g94c63AhzSq4khdL4HlFIP2ePv29smfUnHtGq6yYFDLnT0q/Y+
# Di3jwloF8EWkkHRtSuXlFUbTmwr/lDDgbpZiKhLS7CBTDj32I0L5i532+uHczw82
# oZDmYmYmIUSMbZOgS65h797rj5JJ6OkeEUJoAVwwggd6MIIFYqADAgECAgphDpDS
# AAAAAAADMA0GCSqGSIb3DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0
# ZSBBdXRob3JpdHkgMjAxMTAeFw0xMTA3MDgyMDU5MDlaFw0yNjA3MDgyMTA5MDla
# MH4xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMT
# H01pY3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTEwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQCr8PpyEBwurdhuqoIQTTS68rZYIZ9CGypr6VpQqrgG
# OBoESbp/wwwe3TdrxhLYC/A4wpkGsMg51QEUMULTiQ15ZId+lGAkbK+eSZzpaF7S
# 35tTsgosw6/ZqSuuegmv15ZZymAaBelmdugyUiYSL+erCFDPs0S3XdjELgN1q2jz
# y23zOlyhFvRGuuA4ZKxuZDV4pqBjDy3TQJP4494HDdVceaVJKecNvqATd76UPe/7
# 4ytaEB9NViiienLgEjq3SV7Y7e1DkYPZe7J7hhvZPrGMXeiJT4Qa8qEvWeSQOy2u
# M1jFtz7+MtOzAz2xsq+SOH7SnYAs9U5WkSE1JcM5bmR/U7qcD60ZI4TL9LoDho33
# X/DQUr+MlIe8wCF0JV8YKLbMJyg4JZg5SjbPfLGSrhwjp6lm7GEfauEoSZ1fiOIl
# XdMhSz5SxLVXPyQD8NF6Wy/VI+NwXQ9RRnez+ADhvKwCgl/bwBWzvRvUVUvnOaEP
# 6SNJvBi4RHxF5MHDcnrgcuck379GmcXvwhxX24ON7E1JMKerjt/sW5+v/N2wZuLB
# l4F77dbtS+dJKacTKKanfWeA5opieF+yL4TXV5xcv3coKPHtbcMojyyPQDdPweGF
# RInECUzF1KVDL3SV9274eCBYLBNdYJWaPk8zhNqwiBfenk70lrC8RqBsmNLg1oiM
# CwIDAQABo4IB7TCCAekwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFEhuZOVQ
# BdOCqhc3NyK1bajKdQKVMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsGA1Ud
# DwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFHItOgIxkEO5FAVO
# 4eqnxzHRI4k0MFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly9jcmwubWljcm9zb2Z0
# LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcmwwXgYIKwYBBQUHAQEEUjBQME4GCCsGAQUFBzAChkJodHRwOi8vd3d3Lm1p
# Y3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dDIwMTFfMjAxMV8wM18y
# Mi5jcnQwgZ8GA1UdIASBlzCBlDCBkQYJKwYBBAGCNy4DMIGDMD8GCCsGAQUFBwIB
# FjNodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2RvY3MvcHJpbWFyeWNw
# cy5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AcABvAGwAaQBjAHkA
# XwBzAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIBAGfyhqWY
# 4FR5Gi7T2HRnIpsLlhHhY5KZQpZ90nkMkMFlXy4sPvjDctFtg/6+P+gKyju/R6mj
# 82nbY78iNaWXXWWEkH2LRlBV2AySfNIaSxzzPEKLUtCw/WvjPgcuKZvmPRul1LUd
# d5Q54ulkyUQ9eHoj8xN9ppB0g430yyYCRirCihC7pKkFDJvtaPpoLpWgKj8qa1hJ
# Yx8JaW5amJbkg/TAj/NGK978O9C9Ne9uJa7lryft0N3zDq+ZKJeYTQ49C/IIidYf
# wzIY4vDFLc5bnrRJOQrGCsLGra7lstnbFYhRRVg4MnEnGn+x9Cf43iw6IGmYslmJ
# aG5vp7d0w0AFBqYBKig+gj8TTWYLwLNN9eGPfxxvFX1Fp3blQCplo8NdUmKGwx1j
# NpeG39rz+PIWoZon4c2ll9DuXWNB41sHnIc+BncG0QaxdR8UvmFhtfDcxhsEvt9B
# xw4o7t5lL+yX9qFcltgA1qFGvVnzl6UJS0gQmYAf0AApxbGbpT9Fdx41xtKiop96
# eiL6SJUfq/tHI4D1nvi/a7dLl+LrdXga7Oo3mXkYS//WsyNodeav+vyL6wuA6mk7
# r/ww7QRMjt/fdW1jkT3RnVZOT7+AVyKheBEyIXrvQQqxP/uozKRdwaGIm1dxVk5I
# RcBCyZt2WwqASGv9eZ/BvW1taslScxMNelDNMYIVdDCCFXACAQEwgZUwfjELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQx
# HjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEoMCYGA1UEAxMfTWljcm9z
# b2Z0IENvZGUgU2lnbmluZyBQQ0EgMjAxMQITMwAAAd9r8C6Sp0q00AAAAAAB3zAN
# BglghkgBZQMEAgEFAKCBrjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgiNSBbzgP
# mXJFClV/0G2USLWJdzc2uEGbnSpC7w66uScwQgYKKwYBBAGCNwIBDDE0MDKgFIAS
# AE0AaQBjAHIAbwBzAG8AZgB0oRqAGGh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbTAN
# BgkqhkiG9w0BAQEFAASCAQAvyHZpHf3pwpI9r7h5D5SvD06GqC164hsSChThdxNU
# hf4N5CMU5563CTOYLzZrd/z84t/X0iDFBKsxExdrnjFA+U96iFj1gXovF/m0emXv
# 2IDdMXWXWkO1An6WHLRhkLckXhmGnPIto2X+8XQ/b3/EiICFZXgdSkcsnCjFFkrQ
# 5ahQ2o3cTa3JZw8PoVrZdvjENLpbYrqvG5qM2vNhJAdoePsE/l1LYsAk0IZh0bzn
# P6clIalGaR3YOB51jF/eKI8P5ggYDFN2BamOdXugjTAPOq0M4zwazDg6FW0oJWz8
# sG8g3fo1OL3aWs/d+7nt/TJWczug9+EFQ1LdaXhVve0PoYIS/jCCEvoGCisGAQQB
# gjcDAwExghLqMIIS5gYJKoZIhvcNAQcCoIIS1zCCEtMCAQMxDzANBglghkgBZQME
# AgEFADCCAVkGCyqGSIb3DQEJEAEEoIIBSASCAUQwggFAAgEBBgorBgEEAYRZCgMB
# MDEwDQYJYIZIAWUDBAIBBQAEIIMQudsrMdTYR5ZVgt212Z1Tc1WNlxlUKMl+iUg+
# 8hvcAgZgsOJnpB4YEzIwMjEwNjI0MTQzNTMyLjI4OFowBIACAfSggdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046RTA0MS00QkVFLUZBN0UxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2Wggg5NMIIE+TCCA+GgAwIBAgITMwAAATdBj0PnWltv
# pwAAAAABNzANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMK
# V2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0
# IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0Eg
# MjAxMDAeFw0yMDEwMTUxNzI4MTRaFw0yMjAxMTIxNzI4MTRaMIHSMQswCQYDVQQG
# EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwG
# A1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMS0wKwYDVQQLEyRNaWNyb3NvZnQg
# SXJlbGFuZCBPcGVyYXRpb25zIExpbWl0ZWQxJjAkBgNVBAsTHVRoYWxlcyBUU1Mg
# RVNOOkUwNDEtNEJFRS1GQTdFMSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFt
# cCBTZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxBHuadEl
# m3G5tikhTzjSDB0+9sXmUhUyDVRj0Y4vz9rZ9sykNobL5/6At5zOkeB2bl9IXvVd
# yS/ZJNZT373knzrQ347z30Mmw7++VU/CE+4x4w9kb5bqQHfSzbJQt6KmWsuMmJLz
# g4R5MeJs5MY5YdPLxoMoDRcTi//KoMFR0KzS1/324D2/4KkHD1Xt+s0xY0DICUOK
# 1RbmJCKEgBP1/GDZjuZQBS9Di89yTnvLJV+Lr1QtriH4EqmRoAdmV3zJ0GJsr5vh
# GPmKfOPCRSk7Q8igX7goFnCLzpYcfHGCqoR/mw95gfQpwymVwxZB0PkGMrQw+LKV
# Pa/FHP4C4KO+QQIDAQABo4IBGzCCARcwHQYDVR0OBBYEFA1gsHMM+udgY7rEne66
# OyzxlE9lMB8GA1UdIwQYMBaAFNVjOlyKMZDzQ3t8RhvFM2hahW1VMFYGA1UdHwRP
# ME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1
# Y3RzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNybDBaBggrBgEFBQcBAQROMEww
# SgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMv
# TWljVGltU3RhUENBXzIwMTAtMDctMDEuY3J0MAwGA1UdEwEB/wQCMAAwEwYDVR0l
# BAwwCgYIKwYBBQUHAwgwDQYJKoZIhvcNAQELBQADggEBAJ32U9d90RVuAUb9NsnX
# BG1K42qjhU+jHvwBdbipIcX4Wg7dH5ZduQZj3gWgKADZ5z+TehX7GnBbi265VI7x
# DRsFe2CjkTm4JIoisdKwYBDruS+YRRBG4B1ERuWi54XGwx+lSA+iQNrIi6Jm0CL/
# MfQLvwsqPJSGP69OEHCyaExos486+X3JTuGV11CBl/BO7r8UHbx/rE6fZrlZZYab
# IF6aeahvTL14LvZLV/bMzYSODsbjHHsTm9QaGm1ijhagCdbkAqr8+7HAgYEar8XP
# lzxUhVI4ShVB5ZGd9gZ2yBkwxdA0oFc745TdOPrbP79vd0ePqgvJDH5tkOhTRNI5
# 5XQwggZxMIIEWaADAgECAgphCYEqAAAAAAACMA0GCSqGSIb3DQEBCwUAMIGIMQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIwMAYDVQQDEylNaWNy
# b3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAxMDAeFw0xMDA3MDEy
# MTM2NTVaFw0yNTA3MDEyMTQ2NTVaMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX
# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg
# Q29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAy
# MDEwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqR0NvHcRijog7PwT
# l/X6f2mUa3RUENWlCgCChfvtfGhLLF/Fw+Vhwna3PmYrW/AVUycEMR9BGxqVHc4J
# E458YTBZsTBED/FgiIRUQwzXTbg4CLNC3ZOs1nMwVyaCo0UN0Or1R4HNvyRgMlhg
# RvJYR4YyhB50YWeRX4FUsc+TTJLBxKZd0WETbijGGvmGgLvfYfxGwScdJGcSchoh
# iq9LZIlQYrFd/XcfPfBXday9ikJNQFHRD5wGPmd/9WbAA5ZEfu/QS/1u5ZrKsajy
# eioKMfDaTgaRtogINeh4HLDpmc085y9Euqf03GS9pAHBIAmTeM38vMDJRF1eFpwB
# BU8iTQIDAQABo4IB5jCCAeIwEAYJKwYBBAGCNxUBBAMCAQAwHQYDVR0OBBYEFNVj
# OlyKMZDzQ3t8RhvFM2hahW1VMBkGCSsGAQQBgjcUAgQMHgoAUwB1AGIAQwBBMAsG
# A1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFNX2VsuP6KJc
# YmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6Ly9jcmwubWljcm9z
# b2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1dF8yMDEwLTA2LTIz
# LmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIwMTAtMDYtMjMuY3J0
# MIGgBgNVHSABAf8EgZUwgZIwgY8GCSsGAQQBgjcuAzCBgTA9BggrBgEFBQcCARYx
# aHR0cDovL3d3dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQUy9kZWZhdWx0Lmh0
# bTBABggrBgEFBQcCAjA0HjIgHQBMAGUAZwBhAGwAXwBQAG8AbABpAGMAeQBfAFMA
# dABhAHQAZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOCAgEAB+aIUQ3ixuCY
# P4FxAz2do6Ehb7Prpsz1Mb7PBeKp/vpXbRkws8LFZslq3/Xn8Hi9x6ieJeP5vO1r
# VFcIK1GCRBL7uVOMzPRgEop2zEBAQZvcXBf/XPleFzWYJFZLdO9CEMivv3/Gf/I3
# fVo/HPKZeUqRUgCvOA8X9S95gWXZqbVr5MfO9sp6AG9LMEQkIjzP7QOllo9ZKby2
# /QThcJ8ySif9Va8v/rbljjO7Yl+a21dA6fHOmWaQjP9qYn/dxUoLkSbiOewZSnFj
# nXshbcOco6I8+n99lmqQeKZt0uGc+R38ONiU9MalCpaGpL2eGq4EQoO4tYCbIjgg
# tSXlZOz39L9+Y1klD3ouOVd2onGqBooPiRa6YacRy5rYDkeagMXQzafQ732D8OE7
# cQnfXXSYIghh2rBQHm+98eEA3+cxB6STOvdlR3jo+KhIq/fecn5ha293qYHLpwms
# ObvsxsvYgrRyzR30uIUBHoD7G4kqVDmyW9rIDVWZeodzOwjmmC3qjeAzLhIp9cAv
# VCch98isTtoouLGp25ayp0Kiyc8ZQU3ghvkqmqMRZjDTu3QyS99je/WZii8bxyGv
# WbWu3EQ8l1Bx16HSxVXjad5XwdHeMMD9zOZN+w2/XU/pnR4ZOC+8z1gFLu8NoFA1
# 2u8JJxzVs341Hgi62jbb01+P3nSISRKhggLXMIICQAIBATCCAQChgdikgdUwgdIx
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xLTArBgNVBAsTJE1p
# Y3Jvc29mdCBJcmVsYW5kIE9wZXJhdGlvbnMgTGltaXRlZDEmMCQGA1UECxMdVGhh
# bGVzIFRTUyBFU046RTA0MS00QkVFLUZBN0UxJTAjBgNVBAMTHE1pY3Jvc29mdCBU
# aW1lLVN0YW1wIFNlcnZpY2WiIwoBATAHBgUrDgMCGgMVAOq7qDk4iVz8ITuZbUFr
# AG7ecxqcoIGDMIGApH4wfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
# b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3Jh
# dGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwDQYJ
# KoZIhvcNAQEFBQACBQDkfvhVMCIYDzIwMjEwNjI0MjAyNTU3WhgPMjAyMTA2MjUy
# MDI1NTdaMHcwPQYKKwYBBAGEWQoEATEvMC0wCgIFAOR++FUCAQAwCgIBAAICGMcC
# Af8wBwIBAAICEZEwCgIFAOSASdUCAQAwNgYKKwYBBAGEWQoEAjEoMCYwDAYKKwYB
# BAGEWQoDAqAKMAgCAQACAwehIKEKMAgCAQACAwGGoDANBgkqhkiG9w0BAQUFAAOB
# gQB5UGFbpolpZCBO4C7wHjO7gfKC44h81uNzjYRfqwXHnn28GW6icwKCjmqUNhKN
# gAK9JUKQGOJRyvw04v/gf/vJk1WQjfKgECgvIYom/kK7Gp2ZMf2WDbkb7e66lDbd
# A+zUMavrsgSJmkNX4cIEfgvpAa9UIWADndRCwlKXWStefjGCAw0wggMJAgEBMIGT
# MHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdS
# ZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMT
# HU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwAhMzAAABN0GPQ+daW2+nAAAA
# AAE3MA0GCWCGSAFlAwQCAQUAoIIBSjAaBgkqhkiG9w0BCQMxDQYLKoZIhvcNAQkQ
# AQQwLwYJKoZIhvcNAQkEMSIEIKPGEYaT2m9jHv7MI3AScQVUy1yII8KSAPScq8id
# REy4MIH6BgsqhkiG9w0BCRACLzGB6jCB5zCB5DCBvQQgHVl+r8CeBJ0iyX/aGZD2
# YbQ7gk+U7N7BQiTDKAYSHBAwgZgwgYCkfjB8MQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z
# b2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ
# Q0EgMjAxMAITMwAAATdBj0PnWltvpwAAAAABNzAiBCCBmd+DwLn+uKh+KZ9RWqAG
# mKe2ozoI4FHrIG2KcSGESjANBgkqhkiG9w0BAQsFAASCAQClArVDuf5i5s+4J8DE
# M1bd2HldrLwlc8hTtZ3vBt3kLQe48MOmFzRJHA3BA9j9ZGIRNIbyIm6BWM6tx8jU
# DdCwuz35nx94TinyOM26kjeQD4pTSuChjfsguKKfzS/ugeCV0PluZi/JQX8U4bSe
# UuBfV5MRm8TAA8Vcw49BfyNK+vuK8mdpVZEmSbgRD6BfjF6eRPeXhUrHoow15/Ur
# dVuhdxatyQnIZHfTasqH+RTxgl56kK4FcIYu8quHzYc01J+I490K89axKoTZ13NE
# 8C9AXjnvindvCg0OYm1bLX89+MzcrN30wbOgtJBIWoCfkvW5xO5WFMB7mem/llWE
# hPL+
# SIG # End signature block
