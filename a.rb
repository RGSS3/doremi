require './doremi.rb'
require 'execjs'
Doremi.new(<<-'EOF').run
  <seq xmlns:r="react-like" xmlns:d="doremi" xmlns:js="execjs">
     register_ns_text 'execjs', ExecJS
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
