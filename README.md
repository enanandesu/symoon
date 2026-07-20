# Symoon

Symoon 是一个使用 [MoonBit](https://www.moonbitlang.com/) 编写的符号数学与离散数学库，目标是提供类似 SymPy 的表达式构造、化简、求导、求极限、逻辑推理和数论工具。

> 项目仍处于早期开发阶段（`0.1.0`）。目前的 API 和表达式规范可能继续调整，复杂表达式也可能返回未求解的符号形式或 `Unknown`。

## 功能概览

仓库目前提供三个包：

### `src/core`：符号数学核心

- 整数、浮点数、正负无穷、NaN 和符号变量
- 加、减、乘、除、幂和常见初等函数
- 表达式化简与有理化
- 符号求导（支持高阶导数）
- 有限点极限、左右极限和常见不定式识别
- 初步泰勒近似与有界次数的洛必达求解
- 线性方程及线性方程组求解
- 表达式匹配、重写和自定义规则
- 表达式显示和 LaTeX 输出

### `src/logic`：逻辑工具

- 命题逻辑表达式、解析、求值和化简
- NNF、CNF、DNF 和 ANF 范式转换
- 真值表、可满足性、等价性和蕴含判断
- 逻辑门、半加器和全加器
- 一阶逻辑的基础项、公式与解释
- 线性时序逻辑（LTL）的基础表达式与求值
- 逻辑表达式的 LaTeX 输出

### `src/number`：数论与组合数学

- 最大公约数、最小公倍数和扩展欧几里得算法
- 素数判断、素数计数、筛选和随机素数
- 整数分解及 Pollard rho、Pollard p−1、ECM、QS 等接口
- 模逆、中国剩余定理、离散对数和二次剩余
- Fibonacci、Lucas、分拆和二项式等序列与组合函数
- 连分数、Egyptian fraction、Gray code 和 BBP π 十六进制位
- Pell 方程、线性丢番图方程和勾股数组

## 安装

在 MoonBit 项目中添加模块依赖：

```bash
moon add enanandesu/symoon
```

然后在使用方包的 `moon.pkg.json` 中导入需要的子包，例如：

```json
{
  "import": [
    "enanandesu/symoon/src/core",
    "enanandesu/symoon/src/logic",
    "enanandesu/symoon/src/number"
  ]
}
```

只导入实际使用的子包即可。以下示例使用默认包别名 `@core`、`@logic` 和 `@number`。

## 快速上手

### 构造和化简表达式

```moonbit
///|
fn main {
  let x = @core.sym("x")
  let expr = (x + @core.int(1)) * (x - @core.int(1))
  let simplified = @core.simplify(expr)
  println("\{simplified}")
}
```

`Expr` 实现了常用运算符，因此导入 `core` 后可以组合构造器与 `+`、`-`、`*`、`/` 和一元负号。幂运算使用 `@core.pow(base, exponent)`。

### 求导

```moonbit
///|
fn main {
  let x = @core.sym("x")
  let expr = @core.sin(x) * @core.exp(x)
  let derivative = @core.simplify(@core.differentiate(expr, "x"))
  println("\{derivative}")
}
```

高阶导数可通过可选参数 `order` 指定：

```moonbit
let second = @core.differentiate(@core.sin(@core.sym("x")), "x", order=2)
```

### 求极限

```moonbit
///|
fn main {
  let x = @core.sym("x")
  let sinc = @core.sin(x) / x
  let result = @core.limit(sinc, "x", @core.int(0))
  println("\{result}") // Value(1)
}
```

左右极限分别使用 `@core.limit_left` 和 `@core.limit_right`：

```moonbit
let x = @core.sym("x")
let reciprocal = @core.int(1) / (x - @core.int(1))
let from_left = @core.limit_left(reciprocal.copy(), "x", @core.int(1))
let from_right = @core.limit_right(reciprocal, "x", @core.int(1))
```

极限结果类型为：

- `Value(expr)`：有限值
- `PosInf` / `NegInf`：正无穷或负无穷
- `Divergent`：左右行为不一致或明确发散
- `Unknown`：当前算法无法判定

### 线性方程

```moonbit
let x = @core.sym("x")
let solution = @core.solve_linear_equation(
  @core.int(2) * x + @core.int(4),
  @core.int(0),
  "x",
)
```

### 命题逻辑

```moonbit
let a = @logic.logic_symbol("A")
let b = @logic.logic_symbol("B")
let formula = @logic.logic_implies(a, b)
let cnf = @logic.logic_to_cnf(formula)
```

也可以使用 `@logic.logic_parse` 从字符串构造表达式，并使用 `logic_eval`、`logic_truth_table` 或 `logic_satisfiable` 进行分析。

### 数论

```moonbit
let g = @number.gcd(54, 24)             // 6
let factors = @number.factorint(360)    // 素因数及其指数
let primes = @number.primerange(10, 50)
let (value, modulus) = @number.crt([2, 3], [3, 5])
```

## 项目结构

```text
symoon/
├── moon.mod.json
├── src/
│   ├── core/       # 符号表达式、化简、求导、极限和方程求解
│   ├── logic/      # 命题逻辑、一阶逻辑与 LTL
│   └── number/     # 数论、组合数学与整数算法
└── README.md
```

每个目录都是独立的 MoonBit 包，公开接口由对应的 `pkg.generated.mbti` 描述。普通测试以 `_test.mbt` 结尾，白盒测试以 `_wbtest.mbt` 结尾。

## 本地开发

克隆仓库后，在项目根目录运行：

```bash
moon check
moon test
```

修改代码后更新公开接口并格式化：

```bash
moon info
moon fmt
```

如有意修改快照测试的输出，可运行：

```bash
moon test --update
```

## 当前限制

- 极限实现以直接代入、有限的泰勒近似和有界次数的洛必达法则为主，并非完整的渐近分析系统。
- 不定积分和通用级数展开尚未实现。
- 部分数论算法目前面向 `Int` 范围，并不替代大整数或密码学级实现。
- 错误处理和符号假设系统仍在完善中。

欢迎通过 issue 或 pull request 补充算法、测试和文档。

## License

本项目使用 [Apache License 2.0](LICENSE)。
