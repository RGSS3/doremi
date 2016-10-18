require './doremi.rb'
Doremi.new(<<-'EOF').run
  def hello(name)
    puts "M3L raingowly: #{name}"
  end

  <hello>"esphas"</hello>
EOF
