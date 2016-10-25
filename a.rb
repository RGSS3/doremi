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
        <ant       _cmd="ant" />
        <adb       _cmd="adb" />      
    </x:shell>

    module Shell
        def self._shellword(a)
          return '' if !a
          return a  if !a[' ']
          return a  if a[0] == '"' and a[-1] == '"' and !a[1..-2]['""']
          %{"#{a}"}
        end

        x_open(DEF) do |node|
          klass = Class.new(x_pea(node)) do
           def initialize(*args)
            super
            cmdline = [_node.attributes["_cmdline"] || Shell._shellword(_node.attributes["_cmd"]), *@_args.map{|x|Shell._shellword(x)}, *instance_variables.flat_map{|x|
                x.to_s[1] == "_" ? [] : ["--#{x.to_s.sub("@", "")}", Shell._shellword(instance_variable_get("#{x}"))]
            }]
            puts cmdline.join(' ')
            system cmdline.join(' ')
           end
          end
        

          define_singleton_method(node.name) do |*args|
             klass.new(*args)
          end
        end

        createProject package: "com.M3l.RGL"
    end

  </r:root>



  
  
EOF

