terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
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