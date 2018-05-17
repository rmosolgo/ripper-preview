require "webrick"
require "erb"

module App
  def self.start
    production_env = !!ENV["PORT"]

    server = WEBrick::HTTPServer.new(Port: ENV["PORT"] || 9898)

    if production_env
      require_relative "./renderer"
      template = File.read("./index.html.erb")
    end

    server.mount_proc '/' do |request, response|
      if !production_env
        # reload in development
        load "./renderer.rb"
        template = File.read("./index.html.erb")
      end

      renderer = Renderer.new(request: request)
      erb = ERB.new(template).result(renderer.context)
      response.body = erb
      response.status = 200
      response['Content-Type'] = 'text/html'
    end
    trap 'INT' do server.shutdown end
    server.start
  end
end
