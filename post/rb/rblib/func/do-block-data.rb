### do data dict
def my_method
    data = yield if block_given?
    puts "URL: #{data[:url]}"
    puts "SHA256: #{data[:sha256]}"
end

my_method do
    { url: "https://example.com", sha256: "abcd1234" }
end