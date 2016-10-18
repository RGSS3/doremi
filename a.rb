require './doremi.rb'
Doremi.new(<<-'EOF').run
  <seq xmlns:r="react-like" xmlns:d="doremi">
     <r:root>
       a = <Integer>3</Integer> + <Integer>5</Integer>
       p a
     </r:root>
  </seq>
EOF


