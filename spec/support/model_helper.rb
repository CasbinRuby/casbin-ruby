# frozen_string_literal: true

def model_config(name)
  File.expand_path("files/examples/#{name}/model.conf", __dir__)
end

def policy_file(name)
  File.expand_path("files/examples/#{name}/policy", __dir__)
end
