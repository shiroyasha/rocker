require "rest-client"
require "fileutils"

$dockerhub_index = "https://index.docker.io"
$dockerhub_registry = "https://registry-1.docker.io"

module DockerHub
  class RockerImage

    def initialize(repository_name, tag)
      @repository_name = repository_name
      @tag = tag

      @token = fetch_registry_token
    end

    def registry_token
      @token ||= fetch_registry_token
    end

    def registry_id
      @registry_id ||= fetch_registry_id
    end

    def ancestry
      @ancestry ||= fetch_ancestry_list
    end

    private

    def fetch_registry_token
      response = RestClient.get "#{$dockerhub_index}/v1/repositories/#{@repository_name}/images", { "X-Docker-Token" => "true" }

      response.headers[:x_docker_token]
    end

    def fetch_registry_id
      response = RestClient.get "#{$dockerhub_registry}/v1/repositories/#{@repository_name}/tags/#{@tag}", { "Authorization" => "Token #{@token}" }

      response.body.gsub(/"/, "")
    end

    def fetch_ancestry_list
      response = RestClient.get "#{$dockerhub_registry}/v1/images/#{registry_id}/ancestry", { "Authorization" => "Token #{@token}" }

      JSON.parse(response.body)
    end

  end
end


def fetch_layer(token, id)
  FileUtils.mkdir("/tmp/#{id}")

  `curl --silent -L -H "Authorization: Token #{token}" #{$dockerhub_registry}/v1/images/#{id}/layer -o /tmp/#{id}/layer.tar > /dev/null`
end

def fetch_layers(token, layers)
  layers.each do |layer_id|
    puts "Pulling #{layer_id}"

    fetch_layer(token, layer_id)

    `rm -rf /tmp/#{layer_id}`
  end
end

image = DockerHub::RockerImage.new("library/ubuntu", "latest")

fetch_layers(image.registry_token, image.ancestry)
