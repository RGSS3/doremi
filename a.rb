require './doremi.rb'
require './shell.rb'
require './ui.rb'
require 'rake'
require 'thor'
require 'thor/actions'
Doremi.new(<<-'EOF').run
  <r:root>
     Shell.add <x:shell>
        <createProject _cmdline="android create project" activity="Hello" package="com.example.Hello" target="android-23" path="Hello" _path="D:/Android/tools">
            @activity ||= @package.split(".").last.capitalize
            @path     ||= @package.tr(".", "/")
        </createProject>
        <createAVD _cmdline="android create avd" name="Hello" target="android-23" _path="D:/Android/tools"/>
        <ant       _cmd="ant" _path="D:/ant/bin"/>
        <adb       _cmd="adb" _path="D:/Android/tools"/>
    </x:shell>

    UI.add <x:ui>
      <vertical>
         <horizontal><textbox id="textbox"/></horizontal>
           <r:root>
              ["789+", "456-", "123*", "0.=/"].each{|x|
                  <horizontal>
                    <r:root>
                      x.split("").each{|y|
                        <button>y</button>
                      }
                    </r:root>
                  </horizontal>
              }
              <button span="2">'AC'</button>
              <button span="2">'CE'</button>
              ["M+", "M-", "MR", "MC"].each{|x|
                  <button>x</button>
              }
          </r:root>
      </vertical>
    </x:ui>
  </r:root>

   

EOF

