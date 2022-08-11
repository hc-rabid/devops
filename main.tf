terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "2.16.0"
    }
  
  }
}

provider "docker" {
  host    = "unix:///var/run/docker.sock"
}

# Create private network for containers
resource "docker_network" "appnet" {
  name = "appnet"
  driver = "bridge"
}

# Build docker images for server, client, and proxy
resource "docker_image" "server_image" {
  name = "server_image:latest"

  build {
      path = "."
  }
}

resource "docker_image" "client_image" {
  name = "client_image:latest"

  build {
      path = "./public/"
  }

}

resource "docker_image" "proxy_image" {
  name = "proxy_image:latest"

  build {
      path = "./proxy/"
  }
}

# Docker push command to container registry
resource "null_resource" "docker_push" {
    provisioner "local-exec" {
    command = <<-EOT
      docker tag server_image:latest jack.hc-sc.gc.ca/devops/ray-test/server_image:latest
      docker push jack.hc-sc.gc.ca/devops/ray-test/server_image:latest
      docker tag client_image:latest jack.hc-sc.gc.ca/devops/ray-test/client_image:latest
      docker push jack.hc-sc.gc.ca/devops/ray-test/client_image:latest
      docker tag proxy_image:latest jack.hc-sc.gc.ca/devops/ray-test/proxy_image:latest
      docker push jack.hc-sc.gc.ca/devops/ray-test/proxy_image:latest

    EOT
    }
    depends_on = [
      docker_image.server_image, docker_image.client_image, docker_image.proxy_image
    ]
}

resource "docker_container" "server_container" { 
  name  = "server_container"
  image = docker_image.server_image.latest


  networks_advanced {
    name = "appnet"
  }

  # ports{
  #   # external = 81
  #   internal = 80
  # }

  depends_on = [docker_network.appnet]
}

resource "docker_container" "client_container" {
  name  = "client_container"
  image = docker_image.client_image.latest


  networks_advanced {
    name = "appnet"
  }

  # ports{
  #   # external = 82
  #   internal = 80
  # }

  depends_on = [docker_network.appnet]
}



resource "docker_container" "proxy_container" {
  name  = "proxy_container"
  image = docker_image.proxy_image.latest
  restart = "on-failure"
  networks_advanced {
    name = "appnet"
  }
  ports {
    internal = 80
    external = 80
  }

  depends_on = [docker_network.appnet]
}

# resource "docker_container" "server_container" {
#   name = "server_container"
#   image = "server_image:${var.deploy-version}"
#   restart = "always"
#   start = true
#   must_run = true

#     networks_advanced {
#         name = "appnet"
# #        ipv4_address = "172.17.0.5"
#     }
#}