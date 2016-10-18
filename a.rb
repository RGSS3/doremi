require './doremi.rb'
include REXML
Doremi.new(<<-'EOF').run
  def hello(name)
    puts "M3L raingowly: #{name}"
  end

  module MyNamespace
    def self.say(word)
      puts word
    end

    def self.run(*)
      doremi_each{|x|
        case x.name  
          when "say"
            puts x.text.to_s
          when "reverse"
            puts x.text.reverse
          end
      }
    end
  end

  register_ns_text "my", MyNamespace

  <seq xmlns:my="my">
    <my:say>Hello world</my:say>
    <my:run>
       <say>Hello world</say>
       <reverse>World</reverse>
    </my:run>
  </seq>
EOF
