# 序列化
> http://fabien.potencier.org/php-serialization-stack-traces-and-exceptions.html

## problem
A non-serializable object is present in the stack trace:

  $dbh = new PDO('sqlite:memory:');
  function will_crash($dbh)
  {
    // serialize an exception
    echo serialize(new Exception());
  }
  will_crash($dbh);

What happens? When PHP serializes an exception, it serializes the exception code, the exception message, but also the stack trace.

The stack trace contains a reference to the `PDO instance`, and as PDO instances are not serializable, an exception is thrown when PHP serializes the stack trace.

## magic serialize

  class ValidatorError extends Exception implements Serializable {
  	var $validator;
  	var $arguments;

    public function serialize() {
      return serialize(array($this->validator, $this->arguments, $this->code, $this->message));
    }

    public function unserialize($serialized) {
      list($this->validator, $this->arguments, $this->code, $this->message) = unserialize($serialized);
    }
  }
    echo serialize(new ValidatorError('message', 500));
