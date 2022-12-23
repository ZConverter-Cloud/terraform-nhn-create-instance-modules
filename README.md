


# terraform-nhn-create-instnace-modules

> Before You Begin
> 
> Prepare
> 
> Start Terraform



## Before You Begin
To successfully perform this tutorial, you must have the following:

   * An NHN Cloud account. [See Signing Up for NHN Cloud](https://docs.toast.com/en/TOAST/en/user-guide)

## Prepare
Prepare your environment for authenticating and running your Terraform scripts. Also, gather the information your account needs to authenticate the scripts.

### Install Terraform
   Install the latest version of Terraform **v1.3.0+**:

   1. In your environment, check your Terraform version.
      ```script
      terraform -v
      ```

      If you don't have Terraform **v1.3.0+**, then install Terraform using the following steps.

   2. From a browser, go to [Download Latest Terraform Release](https://www.terraform.io/downloads.html).

   3. Find the link for your environment and then follow the instructions for your environment. Alternatively, you can perform the following steps. Here is an example for installing Terraform v1.3.3 on Linux 64-bit.

   4. In your environment, create a temp directory and change to that directory:
      ```script
      mkdir temp
      ```
      ```script
      cd temp
      ```

   5. Download the Terraform zip file. Example:
      ```script
      wget https://releases.hashicorp.com/terraform/1.3.3/terraform_1.3.3_linux_amd64.zip
      ```

   6. Unzip the file. Example:
      ```script
      unzip terraform_1.3.3_linux_amd64.zip
      ```

   7. Move the folder to /usr/local/bin or its equivalent in Mac. Example:
      ```script
      sudo mv terraform /usr/local/bin
      ```

   8. Go back to your home directory:
      ```script
      cd
      ```

   9. Check the Terraform version:
      ```script
      terraform -v
      ```

      Example: `Terraform v1.3.3 on linux_amd64`.

### Get API-Key
   We need the provider information below to use the nhn terraform.
   * **user_name**
	   - Use the NHN Cloud ID.
   * **tenant_id**
	   - From  **Compute > Instance > Management**  on NHN Cloud console, click  **Set API Endpoint**  to check the Tenant ID.
   * **password**
	   - Use  **API Password**  that you saved in  **Set API Endpoint**.
	   - Regarding how to set API passwords, see  **User Guide > Compute > Instance > API Preparations**.
   * **auth_url**
	   - Specify the address of the NHN Cloud identification service.
	   - From  **Compute > Instance > Management**  on NHN Cloud console, click  **Set API Endpoint**  to check Identity URL.
   *   **region**
	   -   Enter the region to manage NHN Cloud resources.
	   -   **KR1**: Korea (Pangyo) Region
	   -   **KR2**: Korea (Pyeongchon) Region
	   -   **JP1**: Japan (Tokyo) Region
	![Account User](https://raw.githubusercontent.com/ZConverter-samples/terraform-nhn-create-instance-modules/main/images/api.png)

##  Start Terraform

* To use terraform, you must have a terraform file of command written and a terraform executable.
* You should create a folder to use terraform, create a `terraform.tf` file, and enter the contents below.
	```
	#Define required providers
	terraform {
		required_version  =  ">= 1.3.0"
		required_providers {
			openstack  =  {
				source = "terraform-provider-openstack/openstack"
				version = "1.48.0"
			}
		}
	}

	#Configure the OpenStack Provider
	provider  "openstack" {
		user_name  = var.terraform_data.provider.user_name
		tenant_id  = var.terraform_data.provider.tenant_id
		password  = var.terraform_data.provider.password
		auth_url  = var.terraform_data.provider.auth_url
		region  = var.terraform_data.provider.region
	}
	
	#variable
	variable  "terraform_data" {
		type  =  object({
			provider = object({
				user_name = string
				tenant_id = string
				password = string
				auth_url = string
				region = string
			})
			vm_info = object({
				vm_name = string
				user_data_file_path = optional(string, null)
				additional_volumes = optional(list(number), [])
				OS = object({
					OS_name = string
					OS_version = string
					boot_size = optional(number, 20)
				})
				network_interface = object({
					network_name = string
					create_security_group_name = string
					create_security_group_rules = optional(list(object({
						direction = optional(string,null)
						ethertype = optional(string,null)
						protocol = optional(string,null)
						port_range_min = optional(string,null)
						port_range_max = optional(string,null)
						remote_ip_prefix = optional(string,null)
					})), null)
				})
				flavor = object({
					flavor_name = string
				})
				ssh_authorized_keys = optional(object({
					key_pair_name = optional(string, null)
					create_key_pair_name = optional(string, null)
					ssh_public_key = optional(string, null)
					ssh_public_key_file = optional(string, null)
				}), {
					key_pair_name = null
					create_key_pair_name = null
					ssh_public_key = null
					ssh_public_key_file = null
				})
			})
		})
		default  =  {
			provider = {
				auth_url = null
				password = null
				region = null
				tenant_id = null
				user_name = null
			}
			vm_info = {
				additional_volumes = []
				flavor = {
					flavor_name = null
				}
				network_interface = {
					create_security_group_name = null
					create_security_group_rules = [{
						direction = null
						ethertype = null
						protocol = null
						port_range_min = null
						port_range_max = null
						remote_ip_prefix = null
					}]
					network_name = null
				}
				OS = {
					OS_name = null
					OS_version = null
					boot_size = 20
				}
				ssh_authorized_keys = {
					create_key_pair_name = null
					key_pair_name = null
					ssh_public_key = null
					ssh_public_key_file = null
				}
				user_data_file_path = null
				vm_name = null
			}
		}
	}

	#create_instance
	module  "create_nhn_instance" {
		source  =  "git::https://github.com/ZConverter-samples/terraform-nhn-create-instance-modules.git"
		region  = var.terraform_data.provider.region
		vm_name  = var.terraform_data.vm_info.vm_name
		
		OS  = var.terraform_data.vm_info.OS.OS_name
		OS_version  = var.terraform_data.vm_info.OS.OS_version
		boot_size  = var.terraform_data.vm_info.OS.boot_size
		
		flavor_name  = var.terraform_data.vm_info.flavor.flavor_name
		
		key_pair_name  = var.terraform_data.vm_info.ssh_authorized_keys.key_pair_name
		create_key_pair_name  = var.terraform_data.vm_info.ssh_authorized_keys.create_key_pair_name
		ssh_public_key  = var.terraform_data.vm_info.ssh_authorized_keys.ssh_public_key
		ssh_public_key_file  = var.terraform_data.vm_info.ssh_authorized_keys.ssh_public_key_file
		
		network_name  = var.terraform_data.vm_info.network_interface.network_name
		create_security_group_name  = var.terraform_data.vm_info.network_interface.create_security_group_name
		create_security_group_rules  = var.terraform_data.vm_info.network_interface.create_security_group_rules
		
		user_data_file_path  = var.terraform_data.vm_info.user_data_file_path
		additional_volumes  = var.terraform_data.vm_info.additional_volumes
	}

	output  "result" {
		value  =  module.create_nhn_instance.result
	}
   ```
* After creating the nhn_terraform.json file to enter the user's value, you must enter the contents below. 
* ***The nhn_terraform.json below is an example of a required value only. See below the Attributes table for a complete example.***
* ***There is an attribute table for input values under the script, so you must refer to it.***
	```
	{
		"terraform_data" : {
			"provider" : {
				"auth_url" : "https://api-identity.infrastructure.cloud.toast.com/v2.0",
				"tenant_id" : "66***********************************",
				"user_name" : "********@yournhnemail.com",
				"password" : "***************",
				"region" : "KR1"
			},
			"vm_info" : {
				"vm_name" : "test",
				"OS" : {
					"OS_name" : "ubuntu server",
					"OS_version" : "18.04",
					"boot_size" : 30
				},
				"network_interface" : {
					"network_name" : "Default Network",
					"create_security_group_name" : "security_group1",
					"create_security_group_rules" : [
						{
							"direction" : "ingress",
							"ethertype" : "IPv4",
							"protocol" : "tcp",
							"port_range_min" : "22",
							"port_range_max" : "22",
							"remote_ip_prefix" : "0.0.0.0/0"
						}
					]
				},
				"flavor" : {
					"flavor_name" : "m2.c2m4"
				},
				"ssh_authorized_keys" : {
					"create_key_pair_name" : "test-key",
					"ssh_public_key" : "ssh-rsa AAAAB3NzaC1yc2EA**********************"
				},
				"additional_volumes" : [50]
			}
		}
	}
	```
### Attribute Table
|Attribute|Data Type|Required|Default Value|Description|
|---------|---------|--------|-------------|-----------|
| terraform_data.provider.auth_url | string | yes | none |The auth_url you recorded in the memo during the [preparation step](#get-api-key).|
| terraform_data.provider.tenant_id | string | yes | none |The tenant_id you recorded in the memo during the [preparation step](#get-api-key).|
| terraform_data.provider.user_name | string | yes | none |The user_name you recorded in the memo during the [preparation step](#get-api-key).|
| terraform_data.provider.password | string | yes | none |The password you recorded in the memo during the [preparation step](#get-api-key).|
| terraform_data.provider.region | string | yes | none |The region you recorded in the memo during the [preparation step](#get-api-key).|
| terraform_data.vm_info.vm_name | string | yes | none |The name of the instance you want to create.|
| terraform_data.vm_info.OS.OS_name | string | yes | none |Enter the OS name you want to create among (windows, centos, ubuntu server, rocky, debian buster, debian bullseye).|
| terraform_data.vm_info.OS.OS_version | string | yes | none |The version of the OS you want to create.|
| terraform_data.vm_info.OS.boot_size | number | no | 20 |Boot volume size of the instance you want to create.|
| terraform_data.vm_info.flavor.flavor_name| string | yes | none |flavor types provided by NHN Cloud.|
| terraform_data.vm_info.network_interface.network_name | string | yes | none | The name of the VPC you want to use.|
| terraform_data.vm_info.network_interface.create_security_group_name | string | no | none | The name of the Security-Group to create.|
| terraform_data.vm_info.network_interface.create_security_group_rules | list | no | none |	When you need to create ingress and egress rules.|
| terraform_data.vm_info.network_interface.create_security_group_rules.[*].direction | stirng | conditional | none | Either "ingress" or "egress"|
| terraform_data.vm_info.network_interface.create_security_group_rules.[*].ethertype | string | conditional | none | Either "IPv4" or "IPv6" |
| terraform_data.vm_info.network_interface.create_security_group_rules.[*].protocol | string | conditional | none | Enter a supported protocol name |
| terraform_data.vm_info.network_interface.create_security_group_rules.[*].port_range_min | string | conditional | none | Minimum Port Range (Use only when using udp, tcp protocol) |
| terraform_data.vm_info.network_interface.create_security_group_rules.[*].port_range_max | string | conditional | none | Maximum Port Range (Use only when using udp, tcp protocol) |
| terraform_data.vm_info.network_interface.create_security_group_rules.[*].remote_ip_prefix | string | conditional | none | CIDR (ex : 0.0.0.0/0) |
| terraform_data.vm_info.ssh_authorized_keys.ssh_public_key | string | conditional | none | ssh public key to use when using Linux-based OS. (Use only one of the following: ssh_public_key, ssh_public_key_file_path) |
| terraform_data.vm_info.ssh_authorized_keys.ssh_public_key_file | string | conditional | none | Absolute path of ssh public key file to use when using Linux-based OS. (Use only one of the following: ssh_public_key, ssh_public_key_file_path) |
| terraform_data.vm_info.user_data_file_path | string | conditional | none | Absolute path of user data file path to use when cloud-init. |
| terraform_data.vm_info.additional_volumes | string | conditional | none | Use to add a block volume. Use numeric arrays. |

* oci_terraform.json Full Example

   ```
   {
      "terraform_data" : {
         "provider" : {
            "tenancy_ocid" : null,
            "user_ocid" : null,
            "fingerprint" : null,
            "private_key_path" : null,
            "region" : null
        },
        "vm_info" : {
            "region" : null,
            "vm_name" : null,
            "user_data_file_path" : null,
            "additional_volumes" : null,
            "OS" : {
               "OS_name" : null,
               "OS_version" : null,
               "boot_volume_size_in_gbs" : null
            },
            "flavor" : {
               "flavor_name" : null
            },
            "network_interface" : {
	           "create_security_group_name" : null
               "create_security_group_rules" : [
                  {
                     "direction" : null,
                     "protocol" : null,
                     "port_range_min" : null,
                     "port_range_max" : null,
                     "remote_ip_prefix" : null,
                  }
               ]
            },
            "ssh_authorized_keys" : {
               "ssh_public_key" : null,
               "ssh_public_key_file" : null
            }
         }
      }
   }
   ```

* **Go to the file path of Terraform.exe and Initialize the working directory containing the terraform configuration file.**

   ```
   terraform init
   ```
   * **Note**
       -chdir : When you use a chdir the usual way to run Terraform is to first switch to the directory containing the `.tf` files for your root module (for example, using the `cd` command), so that Terraform will find those files automatically without any extra arguments. (ex : terraform -chdir=\<terraform data file path\> init)

* **Creates an execution plan. By default, creating a plan consists of:**
  * Reading the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
  * Comparing the current configuration to the prior state and noting any differences.
  * Proposing a set of change actions that should, if applied, make the remote objects match the configuration.
   ```
   terraform plan -var-file=<Absolute path of nhn_terraform.json>
   ```
  * **Note**
	* -var-file : When you use a var-file Sets values for potentially many [input variables](https://www.terraform.io/docs/language/values/variables.html) declared in the root module of the configuration, using definitions from a ["tfvars" file](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files). Use this option multiple times to include values from more than one file.
     * The file name of vars.tfvars can be changed.

* **Executes the actions proposed in a Terraform plan.**
   ```
   terraform apply -var-file=<Absolute path of nhn_terraform.json> -auto-approve
   ```
* **Note**
	* -auto-approve : Skips interactive approval of plan before applying. This option is ignored when you pass a previously-saved plan file, because Terraform considers you passing the plan file as the approval and so will never prompt in that case.
