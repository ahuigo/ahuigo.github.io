---
title: Python 的类型注解
date: 2019-10-03
---
# vscode python type check
## install pylance
https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance

    Type checking mode
    Signature help, with type information
    Parameter suggestions
    Code completion
    Auto-imports (as well as add and remove import code actions)
    As-you-type reporting of code errors and warnings (diagnostics)
    Code outline
    Code navigation
    Native multi-root workspace support
    IntelliCode compatibility
    Jupyter Notebooks compatibility
    Semantic highlighting

## open pylance

    "python.analysis.typeCheckingMode": "basic"

## ignore warning
在行后面加：`# type: ignore `

    import _io # type: ignore

vscode 中：

    "reportUnusedImport": "information",
    "python.analysis.diagnosticSeverityOverrides": {
        "reportMissingImports": "none",
        "reportAttributeAccessIssue":"none"
    },

# Python 的类型注解
> 代码参考 pylib/spec/types/
python 也向typescript 学习 也自己加类型系统了。本文对此做个笔记

## 类型系统
    def greeting(name: str) -> str:
        return 'Hello ' + name

## type alias
    from typing import List
    Vector = List[float]

    def scale(scalar: float, vector: Vector) -> Vector:
        return [scalar * num for num in vector]

    # typechecks; a list of floats qualifies as a Vector.
    new_vector = scale(2.0, [1.0, -4.2, 5.4])

类型别名可用于简化复杂类型签名。例如:

    from typing import Dict, Tuple, Sequence, Set

    ConnectionOptions = Dict[str, str]
    Address = Tuple[str, int]
    Server = Tuple[Address, ConnectionOptions]

    def broadcast_message(message: str, servers: Sequence[Server]) -> None:
        ...

    # The static type checker will treat the previous type signature as
    # being exactly equivalent to this one.
    def broadcast_message(
            message: str,
            servers: Sequence[Tuple[Tuple[str, int], Dict[str, str]]]) -> None:
        ...

请注意，None 作为类型提示是一种特殊情况，并且由 type(None) 取代。


## NewType
使用 NewType() 辅助函数创建不同的类型:

    from typing import NewType

    UserId = NewType('UserId', int)
    some_id = UserId(524313)

静态类型检查器会将新类型视为它是原始类型的子类。这对于帮助捕捉逻辑错误非常有用:

    def get_user_name(user_id: UserId) -> str:
        ...

    # typechecks
    user_a = get_user_name(UserId(42351))

    # does not typecheck; an int is not a UserId
    user_b = get_user_name(-1)

您仍然可以对 UserId 类型的变量执行所有的 int 支持的操作，但结果将始终为 int 类型。这可以让你在需要 int 的地方传入 UserId，但会阻止你以无效的方式无意中创建 UserId:

    # 'output' is of type 'int', not 'UserId'
    output = UserId(23413) + UserId(54341)

## 泛型(Generic)
由于无法以通用方式静态推断有关保存在容器中的对象的类型信息，因此抽象基类已扩展为支持订阅以表示容器元素的预期类型。

    from typing import Mapping, Sequence

    def notify_by_email(employees: Sequence[Employee],
                        overrides: Mapping[str, str]) -> None: ...

泛型可以通过使用typing模块中名为 TypeVar 的新工厂进行参数化。

    from typing import Sequence, TypeVar

    T = TypeVar('T')      # Declare type variable

    def first(l: Sequence[T]) -> T:   # Generic function
        return l[0]

### Set
    from typing import Dict, Tuple, Sequence, Set
    Set[str]

### 用户定义的泛型类型
用户定义的类可以定义为泛型类。

    from typing import TypeVar, Generic
    from logging import Logger

    T = TypeVar('T')

    class LoggedVar(Generic[T]):
        def __init__(self, value: T, name: str, logger: Logger) -> None:
            self.name = name
            self.logger = logger
            self.value = value

        def set(self, new: T) -> None:
            self.log('Set ' + repr(self.value))
            self.value = new

        def get(self) -> T:
            self.log('Get ' + repr(self.value))
            return self.value

        def log(self, message: str) -> None:
            self.logger.info('%s: %s', self.name, message)

`Generic[T]` 作为基类定义了类 LoggedVar 采用单个类型参数 T。这也使得 T 作为类体内的一个类型有效。

Generic 基类使用定义了 `__getitem__()` 的元类，以便 `LoggedVar[t]` 作为类型有效:

    from typing import Iterable

    def zero_all_vars(vars: Iterable[LoggedVar[int]]) -> None:
        for var in vars:
            var.set(0)