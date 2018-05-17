require "ripper"
require "rouge"
require "pp"

module App
  class Renderer
    attr_reader :code
    def initialize(request:)
      @request = request
      @code = request.query["code"]
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
  end
end
