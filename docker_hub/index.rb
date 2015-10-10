module DockerHub
  module Index
    extend self

    URL = "https://index.docker.io/v1"

    def fetch_repository_access_token(repository_name)
      path = "#{DockerHub::Index::URL}/repositories/#{repository_name}/images"

      RestClient.get(path, "X-Docker-Token" => "true").headers[:x_docker_token]
    end
  end
end
