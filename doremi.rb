require 'rexml/document'
require 'rexml/xpath'
class Doremi
  Domain = []
  def initialize(xml, binding = TOPLEVEL_BINDING)
    @xml     = "<seq>\n#{xml}\n</seq>"
    @doc     = REXML::Document.new(@xml)
    @binding = binding
    @ns      = {}
    @context  = []
    registers
  end

  def registers
    register "" do |node|
      node.children.each{|x|
        node.domain.runNode x, node.binding, node.args
      }
      a = node.attributes.map{|k, v| [k, v]}.select{|k, v| !(k =~ /^xmlns:/)}.to_h
      if a.empty?
        node.result = eval("self", node.binding).send(node.name, *node.args, &node.block)
      else
        node.result = eval("self", node.binding).send(node.name, *node.args, a, &node.block)
      end
      node.sink.push node.result if node.sink
    end
    register "doremi" do |node|
      eval("self", node.binding).send(node.name, node)
    end
    register 'react-like' do |node|
      #node is a root
      a = node.children
      b = a.map.with_index{|x, i|      
        case x 
        when REXML::Text
          x
        when REXML::Element
          " ([__node.domain.runNode(__node.children[" + i.to_s + "], __node.binding, __node.args), __node.args.pop][1]) "
        when nil
          ""
        end
      }.join("")
      eval("__node = nil; lambda{|node| __node = node}", node.binding).call(node)
      eval b, node.binding
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
    @sink  = []
    runNode @doc.children.find{|x| x}, @binding, @sink
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
    attr_accessor :args, :block, :result,  :domain, :binding, :sink

    def xlosure
      x = parent.xlosure
      attributes.each{|k, v|
        if k =~ /^xmlns:/
          x[k] = v
        end
      }
      x
    end

    def doremi(domain, binding, sink)
      self.domain = domain
      self.sink   = sink
      domain.push self
      self.args  = []
      self.block = nil
      self.binding = binding
      return domain.ns(self.namespace).call(self)
    ensure
      domain.pop
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

  def register_ns_text(a, b)
     Doremi::Domain.last.register a.to_s do |o|
        name, text = o.name, o.children.map{|x| x.to_s}.join
        o.sink.push b.send(name, text)
     end
  end

  def current_doremi
    Doremi::Domain.last
  end

  def current_doremi_node
    current_doremi.top
  end

  def doremi_each(*a, &b)
    REXML::XPath.each(current_doremi_node, *a, &b)
  end

  def seq(*a)
    a[-1]
  end

  def id(a)
    a
  end
end

include DoremiMixin

