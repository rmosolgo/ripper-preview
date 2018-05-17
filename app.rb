require "webrick"
require "erb"

module App
  def self.start
    server = WEBrick::HTTPServer.new(Port: ENV["PORT"] || 9898)
    server.mount_proc '/' do |request, response|
      load "./renderer.rb"
      template = File.read("./index.html.erb")
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
