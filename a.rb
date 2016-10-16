require 'rexml/document'
class Doremi
  def initialize(xml, binding = TOPLEVEL_BINDING)
    @xml     = xml
    @doc     = REXML::Document.new(@xml)
    @binding = binding
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
    @stack[-2]
  end

  def run
    @stack = []
    runNode @doc.children[1], @binding
    @doc.children[1].result
  end  

  def runNode(node, binding)
    node.doremi self, binding
  end
end

module REXML
  class Element
    attr_accessor :args, :block, :result, :parent
    def doremi(domain, binding) 
      self.parent = domain.top
      domain.push self
      self.args  = []
      self.block = nil
      if self.namespace == "doremi"
        return eval("self", binding).send(name, self, binding, name, &block)
      end
      case name
      when /^[a-z]([^:]*)$/
        children.each{|x|
          domain.runNode x, binding
        }
        self.result = eval("self", binding).send(name, *args, &block)
        parent.args.push self.result if parent
        domain.pop
      end
      
    end
  end

  class Text
    def doremi(domain, binding)
      domain.top.args.push(eval('method("eval")', binding).call(to_s)) if to_s!=""
    end
  end
end


def seq(*, last) 
  last 
end

def id(a)
  a
end

def addBlock(node, binding, name, &block)
  node.parent.block = eval "lambda{#{node.children[0].to_s}}", binding
end

def twice
  yield
  yield
end

r = Doremi.new(%{
 <seq xmlns:ruby="doremi">
   <twice><ruby:addBlock>p "Hello world"</ruby:addBlock></twice>
 </seq>
})

r.run