require './doremi.rb'

Doremi.new(<<-'EOF').run
 
  <seq xmlns:r="react-like" xmlns:d="doremi">
    def html(node)
      node.domain.parent.args.push(node.children.map{|x| x.to_s}.join)
    end
    <r:root>
      a = gets.chomp
      if a == "Y" || a == "y"
        <puts>"You choose yes"</puts>
      else
        puts <d:html>
          <H1>Not found</H1>
        </d:html>
      end
    </r:root>
  </seq>
EOF


