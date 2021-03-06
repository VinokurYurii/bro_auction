# frozen_string_literal: true

class Swagger::Docs::Config
  def self.base_api_controller
    ApiController
  end
end
Swagger::Docs::Config.register_apis(
  "1.0" => {
      # the output location where your .json files are written to
      api_file_path: "public/apidocs/",
      # the URL base path to your API
      base_path: "http://localhost:3000",
      # if you want to delete all .json files at each generation
      clean_directory: true
  }
)
