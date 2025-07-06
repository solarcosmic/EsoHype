# EsoHype
An esoteric programming language written in Lua where you have to be nice.

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
Repeat loops are blocks of code that repeat a certain amount. They start with `repeat x times` where `x` is the number or variable, and end with `endrepeat`.

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