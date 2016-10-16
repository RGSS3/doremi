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

  def runNode(node, bd)
    node.doremi self, bd
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

      if self.namespace == "doremi"
        return eval("self", self.binding).send(name, self, name, &block)
      end
      case name
      when /^[a-z]/
        children.each{|x|
          domain.runNode x, self.binding
        }
        a = self.attributes.map{|k, v| [k, v]}.to_h
        if a.empty? 
          self.result = eval("self", self.binding).send(name, *args, &block)
        else

          self.result = eval("self", self.binding).send(name, *args, a, &block)
        end
        parent.args.push self.result if parent
        domain.pop
      end
      
    end
  end

  class Text
    attr_accessor :binding
    def doremi(domain, binding)
      self.binding = binding
      domain.top.args.push(eval(to_s, binding)) if to_s!=""
    end
  end
end


def seq(*, last) 
  last 
end

def then(node, name, &block)
  block = eval "lambda{#{node.children[0].to_s}}", node.binding
  block.call(node.parent.result)
end

def set(node, name, &block)
  node.domain.push node
  name = node.attributes["name"]
  node.domain.runNode(node.children[0], node.binding)
  val = node.result = node.args[0]
  eval("#{name} = nil; lambda{|#{name}_| #{name} = #{name}_}", node.binding).call(val)
  node.domain.pop
end

def id(a)
  a
end

def addBlock(node, name, &block)
  node.parent.block = eval "lambda{#{node.children[0].to_s}}", node.binding
end

def twice
  yield
  yield
end

r = Doremi.new(%{
 <seq xmlns:d="doremi">
   a = 3
   b = 5
   <p> a + b </p>
 </seq>
})

r.run
