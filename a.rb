require './doremi.rb'
require 'rake'
require 'thor'
require 'thor/actions'
Doremi.new(<<-'EOF').run
  <r:root>
    DEF = <x:shell>
        <createProject _cmdline="android create project" activity="Hello" package="com.example.Hello" target="android-23" path="Hello">
            @activity ||= @package.split(".").last.capitalize
            @path     ||= @package.tr(".", "/")
        </createProject>
        <createAVD _cmdline="android create avd" name="Hello" target="android-23" />
        <ant       _cmdline="ant" />
        <adb       _cmdline="adb" />
        
        
      
    </x:shell>
  </r:root>
  
EOF

