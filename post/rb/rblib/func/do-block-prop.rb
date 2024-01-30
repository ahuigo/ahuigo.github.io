# sample like head in Homebrew's formula.rb
BEGIN {
    class SoftwareSpec
      def url(val = nil, specs = {})
        #self.url = val if val
        p "2. set url:#{val}"
      end
    end
    @head = SoftwareSpec.new()

  def head(val = nil, specs = {}, &block)
    if block
      p "1.block exec"
      @head.instance_eval(&block)
    end
  end
  
  # padd &block to head
  head do
    # @head.url("xxxx")
    url "xxx"
  end
}
  
END {
    class SoftwareSpec2
      def url(val = nil, specs = {})
        #self.url = val if val
        p "set url:#{val}"
      end
      p "222222222222222"
      def echo(&block)
        p "33333333333333"
        p "call print"
        block.call
      end
    end

  class A < SoftwareSpec2
    p do 
      url "xxx2"
    end
  end
  #A.new()
  
}
  
