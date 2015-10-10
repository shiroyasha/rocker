require "rest-client"

require_relative "docker_hub/index"
require_relative "docker_hub/registry_client"
require_relative "docker_hub/image"

image = DockerHub::Image.new("library/ubuntu", "latest")

image.download_layers
image.delete_layers
