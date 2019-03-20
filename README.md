# Simple BC
## *Now with arbitrary precision*

A simplified version of bc (basic calculator) using ANTLR 4 for the Programming Language Concepts class

## Getting Started

### Installing

Have OpenJDK version 8 installed and follow [these instructions](https://github.com/antlr/antlr4/blob/master/doc/getting-started.md) for installing ANTLR 4.

> Note: Make sure ANTLR is in the classpath with `export CLASSPATH=".:/usr/local/lib/antlr-4.7.1-complete.jar:$CLASSPATH"`

### Simple Example

To compile and run a simple calculator, follow these steps

```bash
cd src/
antlr4 SimpleBC.g4
javac SimpleBC*.java
grun SimpleBC exprList -tree ../test/scratchpad.bc
```
### Note on Arbitrary Precision

This version of simple-bc uses the BigDecimal class internally, instead of the double primitive.
Just like bc, the scale is controlled with an internal variable. By default, it is set to 20. 
The following code produces the same output in both bc -l and simple-bc:

```
> scale
20
> 1 / 3
.33333333333333333333
> scale = 3
> scale
3
> 1 / 3
0.333
```


### Testing

Test cases are stored in ./test. Input files should be suffixed with "-input.bc" if they are to be tested.

To run the tests, execute the following commands:
```bash
cd src/
./test-all.sh
```
Each test case is tested at 3 stringency levels. For each test, the script will output a listing like this:
```
[Test Name]
Diff:       [pass|fail]
Float-diff: [pass|fail]
Round-diff: [pass|fail]
```
For each test, we compare the "actual" output (the output from our simple-bc) to the "expected" output (the output from bc -l).
Each stringency level is assessed  as follows:
- **Diff** executes `diff -y [actual] [expected]`. A pass is an exact match for each line in the two files.
- **Float-diff** executes `python3 float-diff.py [actual] [expected]`. `float-diff.py` converts each result in both inputs to the floating points before comparison.
- **Round-diff** executes `python3 round-diff.py [actual] [expected]`. `float-diff.py` converts each result in both inputs to the floating points and rounds them before comparison.  

The **Float-diff** test is used because our simple-bc formerly stores numbers as doubles (which was the desirable behavior discussed in class), while bc has arbitarary precision. Now, despite using arbitray precision, we still cannot achieve full parity with bc, because the core trigonometic functions of the Java Math library only take doubles, not BigDecimals. This leads to inherently less accurate values.

The **Round-diff** test is used becaues some of Java's math functions (e.g. sine) does not have the same accuracy as bc -l. By rounding, we can show that these actual and expected values are more or less the same.

Ideally, a test will pass at all three levels. However, in practice, most tests have floating point issues. Extremely large numbers cannot be adequately represented in the Java double format, and these may cause a test to fail at all levels. Occasionally, the **Float-diff** and **Round-diff** tests are aborted due to encountering strings. 

When a testcase is run, a folder is generated with the same name (without the -input.bc suffix.)
This folder contains the following:
- **actual.txt**: output from our simple-bc
- **expected.txt**: output from bc -l
- **errors.txt**: any errors produced by simple-bc during this run
- **tree.txt**: the parse tree generated during this test
- **diff.txt**: the comparison used for the **Diff** test
- **float-diff.txt**: the comparison used for the **Float-diff** test
- **round-diff.txt**: the comparison used for the **Round-diff** test

Files currently not automatically tested (need user input): `read-function.bc`, `print-function.bc`

Also, the `scratchpad.bc` is configured to be the automatic test file for the VSCode debugger (press "F5").

## Features

### Scoping
Scoping is intended to be accurate to bc, which only applies a sense of scope to functions.
Consider the following from [test/scope-input.bc](test/scope-input.bc).
```
a = 100
{
    a
    a = a + 1
    b = 42
}
a
b
```
The output from `bc` is:
```
100
101
42
```
Indicating that:
- Both a and b were stored in the global scope
- a was not "shadowed" in the inner block, as it was modified in the outer block.

`bc`'s scoping rules mainly involve functions.
From [func-scope-input.bc](func-scope-input.bc):
```
define range(x, y) {
    global = 0 /* oops */
    local = 777
    # setting locals has no effect
    y = y - x 
    x = 0
    return y
}

global = 42
x = 7
y = 999
range(4, 4)

/* test each variable*/
global
local
x
y
```
Results:
```
0
0
777
7
999
```
Conclusions:
- globals can be modified inside of function blocks
- variables created inside function calls are not saved
- arguments that shadow the names of global variables do not affect the global functions

`SimpleBC` follows these same rules.

The 'pseudostatements' outlined [here](https://www.gnu.org/software/bc/manual/html_mono/bc.html#TOC16) were omitted.

## License

The original project was a collaboration between Matthew Booe and William Owens. Any code that can be traced back to that project is licensed under the MIT License (reproduced below). 
All future additions and modifications are covered under the Apache 2.0 License. See the [LICENSE.md](LICENSE.md) file for details.

Original License:
```
MIT License

Copyright (c) 2019 Matthew Booe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
