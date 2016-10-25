module UI
  UI = []
  def self.add(node)
    UI << render(node)
  end

  def self.render(node)
    sink = []
    Doremi.new.runNode(node.elements[1], binding, sink, true)
    p sink
  end

  def self.scan_args(args)
    if args.last.is_a?(Hash)
      return args.shift, args
      
    else
      return {}, args
    end
  end

  def self.method_missing(sym, *args)
    p [sym, *args]
  end
 
end