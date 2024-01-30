module Helper
  def self.write_mock(path, data)
    File.open("test/fixtures/#{path}.json", "w") do |f|
      f.write(JSON.pretty_generate(data))
    end
  end
end