require "ripper"
require "rouge"
require "pp"
require "graphviz"
require "open3"
require "base64"

module App
  class Renderer
    DEFAULT_CODE =  'puts "hello #{world}"'
    attr_reader :code
    def initialize(request:)
      @request = request
      @code = request.query["code"] || DEFAULT_CODE
    end

    def context
      self.class.context(self)
    end

    def self.context(renderer)
      binding
    end

    def parsed_code
      sexp = Ripper.sexp_raw(code)
      source = PP.pp(sexp, StringIO.new).string
      formatter = Rouge::Formatters::HTML.new
      lexer = Rouge::Lexers::Ruby.new
      formatter.format(lexer.lex(source))
    end

    def image_data
      sexp = Ripper.sexp_raw(code)
      graph = Graphviz::Graph.new
      add_children(graph, sexp)
      dot = graph.to_dot
      data = nil
      Open3.popen3("dot", "-Tpng") do |stdin, stdout, stderr, thd|
        stdin.puts(dot)
        stdin.close
        # err = stderr.gets(nil)
        # if err
        #   warn(err)
        # end
        data = stdout.gets(nil)
      end
      Base64.encode64(data)
    end

    private

    # Add the Ruby sexp to the Graphviz node
    def add_children(node, sexp)
      if sexp
        if (!sexp.is_a?(Array)) || (sexp.is_a?(Array) && sexp.first.is_a?(Symbol))
          name, *children = sexp
          child_node = node.add_node(label: name.inspect)
          if children.any?
            children.each { |c| add_children(child_node, c) }
          end
        else
          child_node = node.add_node(label: "[...]")
          sexp.each { |c| add_children(child_node, c) }
        end
      else
        node.add_node(label: "nil")
      end
    end
  end
end
