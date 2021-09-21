//==================================Azure RS============================

resource "azurerm_resource_group_template_deployment" "AzureRouteServer" {
    
    lifecycle {
      ignore_changes = all
  }
  name                = "${var.TAG}-${var.project}-ARS"
  resource_group_name = azurerm_resource_group.rg.name
  deployment_mode = "Incremental"
  debug_level = "requestContent, responseContent"
    parameters_content = jsonencode({
    "project" = {
      value = var.project
    },
    "TAG" = {
      value = var.TAG
    },
    "location" = {
      value = azurerm_resource_group.rg.location
    },
    "RouteServerSubnetID" ={
      value = azurerm_subnet.subnets["RouteServerSubnet"].id
    },
    "RouteServerPIPID" ={
      value = azurerm_public_ip.arspip.id
    }
  })
  template_content = <<TEMPLATE
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "project": {
            "type": "string",
            "metadata": {
                "description": "Project name"
              }
          },
        "TAG": {
            "type": "string",
            "metadata": {
                "description": "Prefix"
              }
          },
        "location": {
            "type": "string",
            "metadata": {
                "description": "Resource location"
              }
          },
        "RouteServerSubnetID": {
            "type": "string",
            "metadata": {
                "description": "RouteServerSubnet ID"
              }
          },
        "RouteServerPIPID": {
            "type": "string",
            "metadata": {
                "description": "RouteServerPIP ID"
              }
          }         
    },

    "variables": {
       "fgRouteServerName": "[concat(parameters('project'),'-',parameters('TAG'),'-RouteServer')]"

    },
    "resources": [
        {
          "type": "Microsoft.Network/virtualHubs",
          "apiVersion": "2020-06-01",
          "name": "[variables('fgRouteServerName')]",
          "location": "[parameters('location')]",
          "properties": {
            "sku": "Standard"
          }
        },
        {
          "type": "Microsoft.Network/virtualHubs/ipConfigurations",
          "apiVersion": "2020-06-01",
          "name":"[concat(variables('fgRouteServerName'), '/', 'ipconfig1') ]",
          "location": "[parameters('location')]",
          "dependsOn": [
            "[resourceId('Microsoft.Network/virtualHubs', variables('fgRouteServerName'))]"
          ],
          "properties": {
            "subnet": {
              "id": "[parameters('RouteServerSubnetID')]"
            },
            "PublicIPAddress": { "id": "[parameters('RouteServerPIPID')]" }
          }
        }
    ],
    "outputs": {
      }
    
}
TEMPLATE


}