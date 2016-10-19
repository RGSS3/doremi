require './doremi.rb'
require 'rake'
require 'tmpdir'
Doremi.new(<<-'EOF').run


  <q:mini>
    <command>Selection.Copy</command>
    <defaultkey>Ctrl-C</defaultkey>
    <action> clipboard.data = selection.text </action>
  </q:mini>
   
  
EOF
