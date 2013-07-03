# Extension for Net::HTTP to allow request caching
module Net
  class HTTP

    def cached_request path, data, headers, key
      begin
        directory_name = 'cache'
        Dir::mkdir(directory_name) unless FileTest::directory?(directory_name)
      end

      file_path = "cache/#{key}.cache"

      if File.exists?(file_path)
        return IO.read(file_path)
      else
        response = self.post2(path, data, headers)
        data = response.body.inflate
        File.open(file_path, 'w') do |f|
          f.puts data
        end
        return data
      end
    end
  end
end