
require 'aruba/api'

Given /^a gzip file named "([^"]*)" with:$/ do |file_name, file_content|
  # step "a 0 byte file named #{file_name}"
  Aruba::Api::write_fixed_size_file(file_name, 0)
  Zlib::GzipWriter.open(file_name) do |gz|
    gz.write file_content
  end
end
