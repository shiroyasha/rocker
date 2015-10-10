module DockerHub
  class RegistryClient
    URL = "https://registry-1.docker.io/v1"

    def initialize(access_token)
      @access_token = access_token
    end

    def image_id(repository_name, tag)
      path = "/repositories/#{repository_name}/tags/#{tag}"

      get(path).body.gsub(/"/, "")
    end

    def image_ancestry(image_id)
      path = "/images/#{image_id}/ancestry"

      JSON.parse(get(path))
    end

    def get(path)
      RestClient.get("#{DockerHub::RegistryClient::URL}#{path}", authorization_header)
    end

    def authorization_header
      { "Authorization" => "Token #{@access_token}" }
    end

    def download_layer(layer_id, output_path)
      path = "#{DockerHub::RegistryClient::URL}/images/#{layer_id}/layer"
      output = "#{output_path}/layer.tar"
      authorization_header = "Authorization: Token #{@access_token}"

      `curl --silent -L -H "#{authorization_header}" #{path} -o #{output} > /dev/null`
    end
  end
end
