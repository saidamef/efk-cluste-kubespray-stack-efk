variable "PROJECT_ID" {
    default= "pocteo-academy-272209"
}

variable "MACHINE_TYPE" {
    default= "custom-2-2048"
}

variable "ZONE" {
    default= "europe-west1-b"
}

variable "REGION" {
    default= "europe-west1"
}

variable "OS_IMAGE" {
    default= "ubuntu-os-cloud/ubuntu-1804-lts"
}


variable "BASTION_PUB_KEY" {
    default= "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDE8sk3iX03YyhPlUHbqpPJ+rPfMyNY+69SBriNNwsnb1qqvMhB7qI7Of+enbWTpIWaYz425T8zRgwfMFe3reMtTsLbAKEq/89+4/o/40HD9a6INVMkWm8fOTXcZXpo3IHdpct5wrmkko4V+QhZa1/BRBOu9k9iwdDItt9vzIpCK/Y9/UE/+6ilu+qBobPiR+fPmtMY2WGxrcS06CLTOthNXQCF1lcfTctcgZZLWKlJaipWf0Ydnx4C0iW6cVqBsJu4NhaeVQt3SunkIRXhZB03H+O+pQSqi5+SESUhtwuHE+nZvUPWknVcCP1PLFCDKoonkLCceWiWeBTNTAejI5tA0Y5WaLL2URDSR9PoG8aX+56ep5e3U4IvAlmQ/NdSKhUZHOV1BQ4pTidFvDlhD7ROtM0Q+71s2ZM5Us5lDn/igkamO+JS00URCYrBCBtxtEjs8e8Xy6Ax4qWTLKD+kqGcLkLS7/fyP6rw7+LiJd23KTkXCMqworUz6GVlwFVGaKWGf+LfrA0eE9OVPCBTwZGqI004b5t9UDVEf+yA+jyA1/iVOwr7KPlihsAwarlDRzFpzjdC9O5oYJDHlYuql5zvYu4n9g7296BJOXMwsKBHUHUHK4aP2nYJB+oLpgMPfIX5Ta5sdkfxz3pq4nOuCUtVr3Bna6KZ7b1o2+O74OVmMw== root"
}


variable "BASTION_PRIV_KEY" {
    default= "~/.ssh/key"
}

variable "BASTION_PUBLIC_IP_NAME" {
    default= "bastion-static-ip"
}


variable "CLUSTER_NAME" {
    default= "kubespray-cluster"
}

variable "IP_CIDR_RANGE" {
    default= "10.240.0.0/24"
}

variable "CLUSTER_FW_ALLOW_INTERNAL_TAG" {
    default= "allow-kubespray-internal"
}


variable "CLUSTER_FW_ALLOW_BASTION_TAG" {
    default= "allow-bastion"
}

variable "BASTION_INTERNAL_IP" {
    default= "10.240.0.103"
}

variable "MASTER_COUNT" {
  default = "1"
 }

variable "WORKER_COUNT" {
    default= "3"
}

