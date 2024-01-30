#################### instance_eval ################
## eval code and return value with "self binding"
##############################################
# 1. eval self
array_second = <<-RUBY
def second
  self[1]
end
RUBY

a = [1, 2, 3]
a.instance_eval(array_second)

p a.second  # returns: 2

# 2. eval func with args
str = "ruby.devscoop.fr"
str.instance_eval do
    # `/` is a method name; and it has one argument
  def /(delimiter)
    split(delimiter) # str.split(delimiter)
  end
end

p str / '.' # returns: ["ruby", "devscoop", "fr"]
p str /'.' # returns: ["ruby", "devscoop", "fr"]


# 3. eval inner variable
class User
    def initialize(email)
      @email = email
    end
end
u = User.new('ruby@devscoop.fr')
p u.instance_eval('@email')  # returns: "ruby@devscoop.fr"
p u.instance_eval { @email } # returns: "ruby@devscoop.fr"


# 3. eval inner method
class User
    private
    def secret_key
      'XX-XXXX-XXXX-XXXX'
    end
  end
u = User.new('ruby@devscoop.fr')
p u.instance_eval('secret_key')  # returns: "XX-XXXX-XXXX-XXXX"
p u.instance_eval { secret_key } # returns: "XX-XXXX-XXXX-XXXX"
