terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = ">= 2.13.0"
    }
  
  }
}

provider "docker" {
  host    = "unix:///var/run/docker.sock"
}

# Create private network for containers
resource "docker_network" "rays-network" {
  name = "rays-network"
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
      # docker tag proxy_image:latest jack.hc-sc.gc.ca/devops/raytest/proxy_image:latest
      # docker push jack.hc-sc.gc.ca/devops/raytest/proxy_image:latest
# Docker push command to container registry
resource "null_resource" "docker_push" {
    provisioner "local-exec" {
    command = <<-EOT
      docker tag server_image:latest jack.hc-sc.gc.ca/devops/raytest/server_image:latest
      docker push jack.hc-sc.gc.ca/devops/raytest/server_image:latest
      docker tag client_image:latest jack.hc-sc.gc.ca/devops/raytest/client_image:latest
      docker push jack.hc-sc.gc.ca/devops/raytest/client_image:latest


    EOT
    }
    depends_on = [
      docker_image.server_image, docker_image.client_image, docker_image.proxy_image
    ]
}

resource "docker_container" "server_container" { 
  name  = "server_container"
  image = docker_image.server_image.name


  networks_advanced {
    name = "rays-network"
  }

  # ports{
  #   # external = 81
  #   internal = 80
  # }

  depends_on = [docker_network.rays-network, null_resource.docker_push]
}

resource "docker_container" "client_container" {
  name  = "client_container"
  image = docker_image.client_image.name


  networks_advanced {
    name = "rays-network"
  }

  # ports{
  #   # external = 82
  #   internal = 80
  # }

  depends_on = [docker_network.rays-network, null_resource.docker_push]
}



resource "docker_container" "proxy_container" {
  name  = "proxy_container"
  image = "proxy_image"
  networks_advanced {
    name = "rays-network"
  }
  ports {
    internal = 443
    external = 443
  }
  ports {
    internal = 8400
    external = 8400
    ip= "127.0.0.1"
  }
  ports {
    internal = 80
    external = 80
  }
  volumes {
		host_path = "/var/opt/devops/ops/raytest/haproxy.cfg"
		container_path = "/usr/local/etc/haproxy/haproxy.cfg"
		read_only = true
	}
	volumes {
		host_path = "/var/opt/devops/ops/certs.d/"
		container_path = "/usr/local/etc/haproxy/certs.d/"
		read_only = true
	}

  depends_on = [docker_network.rays-network, null_resource.docker_push]
}

# resource "docker_container" "server_container" {
#   name = "server_container"
#   image = "server_image:${var.deploy-version}"
#   restart = "always"
#   start = true
#   must_run = true

#     networks_advanced {
#         name = "rays-network"
# #        ipv4_address = "172.17.0.5"
#     }
#}