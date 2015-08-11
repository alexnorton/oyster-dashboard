require_relative 'app'

run Rack::URLMap.new({
 '/' => PublicApp,
 '/journey/import' => ImportApp
})
