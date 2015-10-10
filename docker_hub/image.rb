require "fileutils"

module DockerHub
  class Image
    attr_reader :repository_name
    attr_reader :tag

    def initialize(repository_name, tag)
      @repository_name = repository_name
      @tag = tag
    end

    def id
      @id ||= registry.image_id(repository_name, tag)
    end

    def ancestry
      @ancestry ||= registry.image_ancestry(id)
    end

    def download_layers
      ancestry.each do |layer_id|
        output_path = FileUtils.mkdir("/tmp/#{layer_id}")

        puts "Pulling #{layer_id}"

        registry.download_layer(id, output_path)
      end
    end

    def delete_layers
      ancestry.each { |layer_id| FileUtils.rm_rf("/tmp/#{layer_id}") }
    end

    private

    def registry
      @registry ||= DockerHub::RegistryClient.new(access_token)
    end

    def access_token
      @token ||= DockerHub::Index.fetch_repository_access_token(repository_name)
    end
  end
end
