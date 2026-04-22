#!/usr/bin/env ruby
require 'json'
require 'tempfile'

passed = 0
failed = 0

def run_test(name)
  yield
  puts "  #{name} - PASSED"
  true
rescue => e
  puts "  #{name} - FAILED: #{e.message}"
  false
end

passed += 1 if run_test("Basic Output") {
  puts "Hello from Hummingbird Ruby 3.4!"
}

passed += 1 if run_test("JSON Processing") {
  data = {"name" => "test", "value" => 123}
  json_str = JSON.generate(data)
  parsed = JSON.parse(json_str)
  raise "name mismatch" unless parsed["name"] == "test"
  raise "value mismatch" unless parsed["value"] == 123
}

passed += 1 if run_test("Array Operations") {
  squares = (0..4).map { |x| x ** 2 }
  raise "expected [0,1,4,9,16]" unless squares == [0, 1, 4, 9, 16]
}

passed += 1 if run_test("File Operations") {
  tmpfile = Tempfile.new('ruby-test')
  begin
    tmpfile.write("test content\n")
    tmpfile.rewind
    content = tmpfile.read
    raise "content mismatch" unless content == "test content\n"
  ensure
    tmpfile.close
    tmpfile.unlink
  end
}

failed = 4 - passed
puts "\nResults: #{passed} passed, #{failed} failed"
exit(failed > 0 ? 1 : 0)
