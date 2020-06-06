    class A
      attr_accessor :name
      def self.echo
        self.name = 'self.name'
        #name = 'name'
        p [@name,self.name,name]
      end
    end
    a = A.new
    A.echo #=> "self.name, self.name, self.name"
