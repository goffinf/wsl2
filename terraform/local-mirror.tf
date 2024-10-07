terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc4"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}