require_relative 'app'

run Rack::URLMap.new({
 '/' => Public,
 '/journey/import' => Import
})