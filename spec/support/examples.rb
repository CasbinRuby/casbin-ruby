# frozen_string_literal: true

module Examples
  def get_examples(path)
    File.expand_path("files/#{path}", __dir__)
  end
end
