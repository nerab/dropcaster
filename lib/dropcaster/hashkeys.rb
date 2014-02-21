module Dropcaster
  module HashKeys
    def method_missing(meth, *args)
      m = meth.id2name
      if /=$/ =~ m
        self[m.chop.to_sym] = (args.length < 2 ? args[0] : args)
      else
        self[m.to_sym]
      end
    end
  end
end
