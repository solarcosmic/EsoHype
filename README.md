# EsoHype
An esoteric programming language written in Lua where you have to have manners.

## Limitations & Constraints
- Lines must end with `please` or `pls`
- You cannot nest `if`, `funk`, or `repeat` blocks
- Converting strings to numbers and vice versa is not directly possible
- Arithmetic can only be done in variables
- New lines and comments don't exist for readability purposes, although shown in the docs

Some of these functions are by design and intended to make experimenting with this programming language more difficult.

## How to Run
1. Make sure you have Lua installed on your system (recommended 5.3+) and added to your PATH environment variables.
2. Navigate to the folder where EsoHype is located (should be the same folder as your .hyp files) and run the command in a terminal:
`lua esohype.lua <name>.hyp`
3. Your program should now begin to execute!

## Manners
It is required to have `please` or `pls` where it is required on the line, otherwise the interpreter will refuse to parse it. For example:
```py
can my_string be "Works!" please  # Will work
display my_string pls

can another_string be "Uh oh!"    # Won't work
display another_string pls
```

## Displays
To print out strings, numbers, or variables, you can use `display`. This function only contains one argument, which is what you want to print out. For example:
```py
display 5 pls               # 5
display 2 * 7 pls          # 14
display "this works!" pls  # this works!
```
Variables can also be used.
```py
can x be 27 pls
display x pls              # 27
```
However, the following example below will not work:
```
display 5
```
This is because it is missing the `please` or `pls` keyword at the end of the line.

## Variables
To define variables, you need to ask the interpreter to define it, for example:
```py
can x be 5 pls
```
where `x` is the variable name and `5` is the value you want to set it to, for example, a number.

Variables can be used almost anywhere, for example, in `display` statements:
```py
can y be 27 pls
display y pls # Outputs 27
```

They can also contain strings:
```py
can y be "this works!" pls
display y pls
```
as well as basic arithmetic:
```py
can z be 5 * (2 + 5) pls
display z pls
```
and they can also be mutable (reassigned).
```py
can x be 27 / 2 pls
display x pls # 13.5
can x be 5 * 5 pls
display x pls # 25
```

NOTE: As of version v1.0.0, arithmetic may only be done in variables.

## Repeat Loops
```py
can x be 25 pls
repeat x times (pls)
    display "This will happen 25 times!" pls
endrepeat (pls)
```
Repeat loops are blocks of code that repeat a certain amount. They start with `repeat x times` where `x` is the number or variable, and end with `endrepeat`. ***Repeat loops cannot be nested.***

You may set the repeat count to a number:
```py
repeat 5 times pls
    display "Repeated 5 times!" pls
endrepeat pls
```
Or you may also set it to be a numeric variable:
```py
can count be 7 pls
repeat count times pls
    display "Repeated 7 times!" pls
endrepeat pls
```
If you do set the count to be a numeric variable, it is possible to do this:
```py
can x be 5 pls
repeat x times
    can x be x + 1 pls
    display x pls
endrepeat pls
```
However, instead of running indefinitely until stopped, EsoHype will only grab the count provided when the repeat block is initialised (or initialized), resulting in this output below:
```
6
7
8
9
10
```
Indents are not needed inside a repeat block as they will be ignored by the interpreter, but they make the code easier to read.

### Repeating Indefinitely
Repeating indefinitely is also possible, for example:

```py
can x be 1 pls
repeat
    wait 1 seconds pls
    can x be x * 2 pls
    display x pls
endrepeat
```
[indefinite_multiply.hyp](https://github.com/solarcosmic/EsoHype/blob/main/examples/indefinite_multiply.hyp) - Using indefinite repeat blocks to multiply a number

The above code will keep multiplying `x` by 2 until stopped (Ctrl+C). After a while, you may see the integers going into the negatives, [this is a limitation of integers and how Lua handles it](http://lua-users.org/wiki/IntegerDomain).

*NOTE: **Do not** have a indefinite repeat block without something yielding it! This means, for example, `wait`. Otherwise, this may crash your device.*

## Functions
Functions are blocks of code that can be repeated as many times as you wish. ***Functions cannot be nested.***

To define a function, use the keyword `funk`, then the name of the function (e.g. `sum`) followed by the arguments you wish to provide (don't forget `pls` or `please` at the end). For example:
```py
funk sum first second pls

endfunk
```
Note that all functions must end with `endfunk`, otherwise the rest of the script may fail to execute correctly.

In this example, `first` is our first argument (the first number) and `second` is our second argument (the second number) that will be used when we add them both together.

Since arithmetic can only be handled in variables, let's create a variable, in this case `x`, as a temporary variable to do the addition.
```py
funk sum first second pls
    can x be first + second pls
endfunk
```
We're adding together both first and second as numbers.

Finally, let's print the result to the user and call the function:
```py
funk sum first second pls
    can x be first + second pls
    display x pls
endfunk pls
call sum 5 5 pls
```
Note the last line - `call sum`. The two numbers there are the arguments that we provided (first and second), and `call sum` executes the function named sum.

Running this inside the console, we get this as output:
```
10
```
Check out the example here:
[get_sum.hyp](https://github.com/solarcosmic/EsoHype/blob/main/examples/get_sum.hyp) - Sum of two numbers using a function

## If Statements
An `if` statement compares one value to another, and if it is true, executes code inside the block. ***If statements cannot be nested.***
For example:
```py
can x be 10 pls
if x > 5 pls
    display "x is greater than 5!" pls
endif
```
Note that all `if` blocks must end with `endif` otherwise the script may not run correctly.

It does not necessarily have to be a variable that you're comparing, for example:
```py
if 10 > 5 pls
    display "10 is still greater than 5!"
endif
```
[if_block.hyp](https://github.com/solarcosmic/EsoHype/blob/main/examples/if_block.hyp) - Basic example of comparing two values

You can also compare strings as well.

### Operator Signs
You may use these operator signs in `if` blocks.

`<` less than
`>` greater than
`<=` less than or equal to
`=>` greater than or equal to
`~=` not equal to
`==` equals

## Examples
[fibonacci.hyp](https://github.com/solarcosmic/EsoHype/blob/main/examples/fibonacci.hyp) - Fibonacci sequence
[takeoff.hyp](https://github.com/solarcosmic/EsoHype/blob/main/examples/takeoff.hyp) - Count down from 5 to 0 (takeoff) using a repeat block
[get_sum.hyp](https://github.com/solarcosmic/EsoHype/blob/main/examples/get_sum.hyp) - Sum of two numbers using a function
[if_block.hyp](https://github.com/solarcosmic/EsoHype/blob/main/examples/if_block.hyp) - Basic example of comparing two values
[indefinite_multiply.hyp](https://github.com/solarcosmic/EsoHype/blob/main/examples/indefinite_multiply.hyp) - Using indefinite repeat blocks to multiply a number

To execute any of these examples in your terminal, simply type `lua esohype.lua examples/<name>.hyp`, for example `lua esohype.lua examples/takeoff.hyp`. This assumes `esohype.lua` is in the same folder as `examples`.

## FAQ
#### What is nesting and why can't it be done?
Nesting means to run, for example, functions inside functions. This capability hasn't been created (as of yet), but if anybody would like to contribute (e.g. make a pull request) feel free to do so.