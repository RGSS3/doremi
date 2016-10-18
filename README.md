# doremilasol
DOmain Ruby Extensible Markup Intermediate LAnguage SOLution

**Just another way of writing Ruby/DSL**.  Not to get confused with JSX, which is another way to writing HTML, not JS. 
But it happens to be able to generate components like React, but React requires a JS runtime, Doremi does not always require a Ruby runtime after generation.

Generally, Ruby lacks something acting as Macros in Lisp, and XML even can't run by itself. Put them together to make better use.

several usages:

Normal Ruby plus a root element is a doremi.
``` ruby
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
```



```ruby
require './doremi.rb'

Doremi.new(<<-'EOF').run
  <seq>
    class A
      def add(a, b)
        a + b
      end
    end
    p A.new.add(3, 5)
  </seq>
EOF
```

```ruby
  #when required sinatra and implement d:html
  Doremi.new(<<-'EOF').run
    <get url="/">
      <d:html>
        <H1>Hello world</H1>
      </d:html>
    </get>
  EOF
```

```ruby
  #more dynamic `jsx`
  Doremi.new(<<-'EOF').run
   <seq xmlns:r="react-like">
     <r:root>
       a = <Integer>3</Integer> # method "Kernel#Integer"
       b = <Integer>5</Integer> 
       <p> a + b </p>
     </r:root>
   </seq>
  EOF
   
```



```ruby
r = Doremi.new(<<-'EOF')
 <seq xmlns:d="doremi" xmlns:r="react-like" xmlns:q="quark"> 
    <q:on key="ctrl-c">
      <q:primitive command="selection.copy"></q:primitive>
    </q:on>
    <q:on key="ctrl-v">
      <q:primitive command="selection.paste"></q:primitive>
    </q:on>
 </seq>
EOF
```
