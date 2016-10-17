# doremilasol
DOmain Ruby Extensible Markup Intermediate LAnguage SOLution

**Just another way of writing Ruby/DSL**.  Not to get confused with JSX, which is another way to writing HTML, not JS. 
But it happens to be able to generate components like React, but React requires a JS runtime, Doremi does not always require a Ruby runtime after generation.

Generally, ruby lacks something acting as Macros in Lisp, and XML even can't run by itself. Put them together to make better use.

several usages:
```ruby
  #when required sinatra and implement d:html
  Doremi.new(<<-'EOF')
    <get url="/">
      <d:html>
        <H1>Hello world</H1>
      </d:html>
    </get>
  EOF.run
```

```ruby
  #more dynamic `jsx`
  Doremi.new(<<-'EOF')
   <seq xmlns:r="react-like">
     <r:root>
       a = <Integer>3</Integer> # method "Kernel#Integer"
       b = <Integer>5</Integer> 
       <p> a + b </p>
     </r:root>
   </seq>
  EOF.run
   
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
