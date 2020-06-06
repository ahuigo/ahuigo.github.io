    class A
      @name="ahui"
      def echo
        p @name
      end
      def self.echo
        p @name
      end
      def mod
        @name = 'hilo'
      end
    end
    a = A.new
    A.echo #=> ahui
    a.echo #=> nil
    a.mod 
    a.echo #=> hilo