 module Shell
        def self._shellword(a)
          return '' if !a
          return a  if !a[' ']
          return a  if a[0] == '"' and a[-1] == '"' and !a[1..-2]['""']
          %{"#{a}"}
        end



        def self.add(node)
          x_open(node) do |node|
            klass = Class.new(x_pea(node)) do
            def initialize(*args)
              super
              if _node.attributes["_path"]
                backpath = ENV['path']
                ENV['path'] = _node.attributes["_path"]  + ";" + ENV['path']
              end 
              
              cmdline = [_node.attributes["_cmdline"] || Shell._shellword(_node.attributes["_cmd"]), 
                        *@_args.map{|x|Shell._shellword(x)}, 
                        *instance_variables.flat_map{|x| x.to_s[1] == "_" ? [] : 
                            ["--#{x.to_s.sub("@", "")}", Shell._shellword(instance_variable_get("#{x}"))]
                        }
                        ]
              
              puts cmdline.join(' ')
              system cmdline.join(' ')
              if _node.attributes["_path"]
                ENV['path'] = backpath
              end
            end
            end
          

            define_singleton_method(node.name) do |*args|
              klass.new(*args)
            end
          end
        end

       
    end