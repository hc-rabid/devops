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
  name = "server_image:${var.version}"

  build {
      path = "."
  }
}

resource "docker_image" "client_image" {
  name = "client_image:${var.version}"

  build {
      path = "./public/"
  }

}

resource "docker_image" "proxy_image" {
  name = "proxy_image:${var.version}"

  build {
      path = "./proxy/"
  }
}

# Docker push command to container registry
resource "null_resource" "docker_push" {
    provisioner "local-exec" {
    command = <<-EOT
      docker tag server_image:${var.version} jack.hc-sc.gc.ca/devops/ray-test/server_image:${var.version}
      docker push jack.hc-sc.gc.ca/devops/ray-test/server_image:${var.version}
      docker tag client_image:${var.version} jack.hc-sc.gc.ca/devops/ray-test/client_image:${version}
      docker push jack.hc-sc.gc.ca/devops/ray-test/client_image:${var.version}
      docker tag proxy_image:${var.version} jack.hc-sc.gc.ca/devops/ray-test/proxy_image:${var.version}
      docker push jack.hc-sc.gc.ca/devops/ray-test/proxy_image:${var.version}

    EOT
    }
    depends_on = [
      docker_image.server_image, docker_image.client_image, docker_image.proxy_image
    ]
}

resource "docker_container" "server_container" { 
  name  = "server_container"
  image = docker_image.server_image.var.version


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
  image = docker_image.client_image.var.version


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
  image = "jack.hc-sc.gc.ca/base/haproxy:5.0.118-http"
  restart = "on-failure"
  networks_advanced {
    name = "appnet"
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
		host_path = "/var/opt/devops/ops/raytest/ha-body.cfg"
		container_path = "/usr/local/etc/haproxy/ha-body.cfg"
		read_only = true
	}
	volumes {
		host_path = "/var/opt/devops/ops/certs.d/"
		container_path = "/usr/local/etc/haproxy/certs.d/"
		read_only = true
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