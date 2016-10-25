require 'rexml/document'
require 'rexml/xpath'
require 'ripper'
class Doremi
  Env = Struct.new(:binding, :args, :sink, :block, :domain, :parent)  
  
  Domain = []
  def initialize(xml, binding = TOPLEVEL_BINDING)
    @xml     = "<seq xmlns:r=\"react-like\" xmlns:x=\"xml\" xmlns:d=\"doremi\" xmlns:f=\"\">\n#{xml}\n</seq>"
    @doc     = REXML::Document.new(@xml)
    @binding = binding
    @ns      = {}
    @context  = []
    registers
  end

  def registers
    register "" do |node|
      node.children.each{|x|
        node.current_env.domain.runNode x, node.current_env.binding, node.current_env.args
      }
      a = node.attributes.map{|k, v| [k, v]}.select{|k, v| !(k =~ /^xmlns:/)}.to_h
      if a.empty?
        node.result = eval("self", node.current_env.binding).send(node.name, *node.current_env.args, &node.current_env.block)
      else
        node.result = eval("self", node.current_env.binding).send(node.name, *node.current_env.args, a, &node.current_env.block)
      end
      node.current_env.sink.push node.result if node.current_env.sink
    end
    register "doremi" do |node|
      eval("self", node.current_env.binding).send(node.name, node)
    end
    register 'react-like' do |node|
      #node is a root
      a = node.children
      b = a.map.with_index{|x, i|      
        case x 
        when REXML::Text
          x
        when REXML::Element
          " ([x_node.current_env.domain.runNode(x_node.children[" + i.to_s + "], binding, x_node.current_env.args), x_node.current_env.args.pop][1]) "
        when nil
          ""
        end
      }.join("")
        eval b, node.current_env.binding
    end
    register "xml" do |node|
      node.current_env.sink.push(node)
    end
  end

  def register(a, b = nil, &c)
    @ns[a] = b || c
  end

  def ns(a)
   if @ns.include?(a)
     @ns[a]
   else
     raise "can't find namespace [" + a.to_s + "]"
   end
  end

  def push(obj)
    @stack.push obj
  end

  def pop
    @stack.pop
  end

  def top
    @stack.last
  end

  def parent
    top.domain_parent
  end
  
  def run
    Domain.push self
    @stack = []
    sink  = []
    runNode @doc.children.find{|x| x}, @binding, sink
    @doc.children.find{|x| x}.result
  ensure
    Domain.pop
  end  

  def runNode(node, bd, sink, clear = false)
    if clear
      Domain.push self
      @stack = []
    end
    node.doremi self, bd, sink
    node.result
  ensure
    Domain.pop if clear    
  end
end

module REXML
  class Document
    def xlosure 
      {}
    end
  end

  class Element
    attr_accessor :result,  :domain,  :sink
    def env
       @env ||= []
    end

    def push_env(env)
       self.env.push(env)
    end

    def pop_env
       self.env.pop
    end

    def current_env
       self.env.last
    end

    def xlosure
      x = parent.xlosure
      attributes.each{|k, v|
        if k =~ /^xmlns:/
          x[k] = v
        end
      }
      x
    end

    def operation(domain = self.domain, binding = sef.binding, sink = self.sink)
      push_env(Doremi::Env.new)
      curr = current_env
      curr.domain = domain
      curr.sink   = sink
      domain.push self
      curr.args  = []
      curr.block = nil
      curr.binding = binding
      yield(self)
    ensure
      domain.pop
      pop_env
    end
    
    def doremi(domain, binding, sink)
      push_env(Doremi::Env.new)
      curr = current_env
      curr.domain = domain
      curr.sink   = sink
      domain.push self
      curr.args  = []
      curr.block = nil
      curr.binding = binding
      domain.ns(self.namespace).call(self)
    ensure
      domain.pop
      pop_env
    end
  end

  class Text
    attr_accessor :binding, :result, :sink

    def doremi(domain, binding, sink)
      self.binding = binding
      self.sink = sink
      self.result = eval(to_s, binding) 
      sink.push(self.result) if to_s.strip!="" && to_s != nil && sink
    end
  end
end


module DoremiMixin
  def register_namespace(a, b = nil, &c)
     Doremi::Domain.last.register a.to_s, b, &c
  end
  alias xmlns register_namespace

  def register_ns_text(a, b)
     Doremi::Domain.last.register a.to_s do |o|
        name, text = o.name, o.children.map{|x| x.to_s}.join
        o.current_env.sink.push b.send(name, text)
     end
  end

  def current_doremi
    Doremi::Domain.last
  end
  
  def seq(*a)
    a[-1]
  end

  def id(a)
    a
  end

  def x_node
    current_doremi.top
  end

  def arr2xml(arr)
    case arr
    when Array
        if arr[0].is_a?(Array)
          u = REXML::Element.new("List")
          arr[0].each{|x| u.add(arr2xml(x))}
          return u
        end
        u = REXML::Element.new(arr[0].to_s)
        arr[1..-1].each{|x| u.add(arr2xml(x))}
        u
    else
        REXML::Text.new(arr.to_s)
    end
  end
  def ruby2xml(str)
    r = Ripper.sexp(str)
    arr2xml(r)
  end

  def x_each(*a, &b)
    REXML::XPath.each(x_node, *a, &b)
  end

  def x_open(x, *a, &b)
    REXML::XPath.each(x, *a, &b)
  end

  def x_first(*a, &b)
    REXML::XPath.first(x_node, *a, &b)
  end

  def x_match(*a, &b)
    REXML::XPath.first(x_node, *a, &b)
  end

  def x_self
    eval("self", x_node.binding)
  end

  def x_text
    x_node.text
  end

  def x_newnode(*a)
    REXML::Element.new *a
  end

  def x_pea(node)
       Class.new do 
          define_method(:_node) do
            node
          end
          define_method(:initialize) do |*args|
            @_args = args
            if args.last.is_a?(Hash)
               @_opt = @_args.pop
             else
               @_opt = {}
             end
          
            @_opt.each{|k, v| instance_variable_set "@#{k}", v} 
            instance_eval node.text.to_s
            node.attributes.each{|k, v|
              next if k[0] == "_"
              if !instance_variable_defined?("@#{k}")
                instance_variable_set "@#{k}", v
              end
            }
          end
      end
  end

  def x_newtext(*a)
    REXML::Text.new *a
  end
end

include DoremiMixin



