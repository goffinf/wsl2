terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.4"
    }
  }
  
  required_version = ">= 1.9"
}

output "Greeting"    { value = "Hello World" }