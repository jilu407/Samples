#--------------------------------------------------------------------------------------------
#   Copyright 2016 Sivaprasad Padisetty
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http:#www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#--------------------------------------------------------------------------------------------

# Pre requisites
#   1. Already have a valid Azure account.
#   2. Install the PS module from http://www.windowsazure.com/en-us/downloads.
#   3. Add this is $profile: Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure'
#
# Run the following cmdlets once per workstation.
#   1. Get-AzurePublishSettingsFile
#   2. Import-AzurePublishSettingsFile  'C:\temp\azure.publishsettings’ 
#   3. In case of multiple subscriptions, select one using Select-AzureSubscription
#   4. there should current storage account. (e.g.) Get-AzureSubscription | Set-AzureSubscription -CurrentStorageAccountName (Get-AzureStorageAccount).Label
#
# You need to add either publicDNSName or * to make PS remoting work for non domain machines
#    Make sure you understand the risk before doing this
#    Set-Item WSMan:\localhost\Client\TrustedHosts "*" -Force
#    It is better if you add full DNS name instead of *. Because * will match any machine name
# 
# This script focuses on on basic function, does not include security or error handling.
#
