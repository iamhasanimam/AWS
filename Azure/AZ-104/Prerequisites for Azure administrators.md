### Manage services with the Azure portal

Learning objectives

Describe options for Azure management, including the Azure portal.
Navigate the Azure portal.
Create, customize, and share dashboards.
Find and try out preview features.

Tools that are commonly used for day-to-day management and interaction include:

Azure portal for interacting with Azure via a Graphical User Interface (GUI)
Azure PowerShell and Azure Command-Line Interface (CLI) for command-line and automation-based interactions with Azure
Azure Cloud Shell for a web-based command-line interface
Azure mobile app for monitoring and managing your resources from your mobile device

Azure PowerShell
Azure PowerShell lets you connect to your Azure subscription and manage resources.

For example, Azure PowerShell provides the New-AzVM command that creates a virtual machine for you inside your Azure subscription. To use it, you launch PowerShell and install the Azure PowerShell module if you haven't already done so. Then, sign in to your Azure account using the command Connect-AzAccount and issue a command such as:

```
New-AzVM -ResourceGroupName "MyResourceGroup" -Name "TestVm" -Image "UbuntuLTS" ... 

```