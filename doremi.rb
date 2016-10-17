require 'rexml/document'
class Doremi
  Domain = []
  def initialize(xml, binding = TOPLEVEL_BINDING)
    @xml     = xml
    @doc     = REXML::Document.new(@xml)
    @binding = binding
    @ns      = {}
    @context  = []
    registers
  end

  def registers
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
          " ([__node.domain.runNode(__node.children[" + i.to_s + "], __node.binding), __node.args.pop][1]) "
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
    top.parent
  end

  def run
    Domain.push self
    @stack = []
    runNode @doc.children[1], @binding
    @doc.children[1].result
  ensure
    Domain.pop
  
  end  

  def runNode(node, bd, clear = false)
    if clear
      Domain.push self
      @stack = []
    end
    node.doremi self, bd
    node.result
  ensure
    Domain.pop if clear    
  end
end

module REXML
  class Element
    attr_accessor :args, :block, :result, :parent, :domain, :binding
    def doremi(domain, binding) 
      self.parent = domain.top
      self.domain = domain
      domain.push self
      self.args  = []
      self.block = nil
      self.binding = binding
      eval("__self = nil; lambda{|node| __self = node}", binding).call(self)
      if self.namespace != "" && self.namespace != nil        
        return domain.ns(self.namespace).call(self)
      end
      children.each{|x|
        domain.runNode x, self.binding
      }
      a = self.attributes.map{|k, v| [k, v]}.select{|k, v| !(k =~ /^xmlns:/)}.to_h
      if a.empty?
        self.result = eval("self", self.binding).send(name, *args, &block)
      else
        self.result = eval("self", self.binding).send(name, *args, a, &block)
      end
      parent.args.push self.result if parent
    ensure
      domain.pop
    end
  end

  class Text
    attr_accessor :binding, :result
    def doremi(domain, binding)
      self.binding = binding
      domain.top.args.push(self.result = eval(to_s, binding)) if to_s.strip!="" && to_s != nil && domain.top
    end

    
  end
end

def register_namespace(a, b = nil, &c)
  Doremi::Domain.last.register a, b, &c
end


def seq(*a)
  a[-1]
end

def id(a)
  a
end

def addBlock(node)
   node.domain.parent.block = eval "lambda{
      Doremi.new('').runNode(__self.children[1], __self.binding, true)
   }", node.binding
end