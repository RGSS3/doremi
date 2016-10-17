require './doremi.rb'
require 'sinatra'
Doremi.new(<<-'EOF').run
  <seq xmlns:r="react-like" xmlns:d="doremi">
   
   <![CDATA[
    def html(node)
      node.domain.parent.args.push(node.children.map{|x| x.to_s}.join)
    end

    register_namespace "sinatra" do |node|
       path = node.attributes["url"]
       method = node.name
       node.children.each{|x| node.domain.runNode(x, node.binding) }
       send(method, path, &node.block)
    end
   ]]>

    
    <seq xmlns:s="sinatra">
      <s:get url="/">
       <d:addBlock>
         <seq xmlns:d="doremi" xmlns:s="sinatra">
           <d:html>
             <H1>Hello world</H1>
           </d:html>
         </seq>
        </d:addBlock>
      </s:get>
    </seq>

    
  </seq>
EOF


