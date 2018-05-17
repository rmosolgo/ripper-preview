require "ripper"
require "rouge"
require "pp"

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
  end
end
