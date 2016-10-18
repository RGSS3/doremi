require './doremi.rb'
require 'execjs'
Doremi.new(<<-'EOF').run
  <seq xmlns:r="react-like" xmlns:d="doremi" xmlns:js="execjs">
     register_namespace 'execjs' do |o|
        name = o.name
        text = o.children.map{|x| x.to_s}.join
        o.sink.push ExecJS.send(name, text)
     end
     <r:root>     
       p <js:eval>
         (function(G){
           var s = 0;
           for(var i = 1; i != 101; ++i){
              s += i;
           }
           return s;
          })(this)
      </js:eval>
     </r:root>
  </seq>
EOF


