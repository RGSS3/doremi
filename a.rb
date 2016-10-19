require './doremi.rb'
Doremi.new(<<-'EOF').run
 <seq xmlns:r="react-like">
  <r:root xmlns:m="macro">
    register_namespace "macro", Module.new{
        def self.call(node)
           send node.name, node
        end
        def self.attr_accessor(node)
          x_each("li"){|x|
            x_self.send(:attr_accessor, x.text)
          }
        end
    }
    class A
       <m:attr_accessor>
         <li>a</li>
         <li>b</li>
         <li>c</li>
       </m:attr_accessor>
    end
    x = A.new
    x.a = 3
    p x.a
    p x.methods - Object.instance_methods
  </r:root>
 </seq>
EOF
