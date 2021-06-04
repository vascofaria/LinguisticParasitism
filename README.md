# LinguisticParasitism
Group 9 - Advanced Programming 20/21

## Run in Linux:

```sh
export JULIA_COPY_STACKS=1
julia main.jl
```

# Usage

## How to import our lib

```jl
include("lib/JavaParasit.jl")
```

## How to import a Java Class

```jl
# importClass(className)
ParasitString = importClass("java.lang.String")
```

## How to create an instance of the class

```jl
# @new Class arg1 arg2 ...
str = @new ParasitString "  hello world!"
```

## How to call a static function

```jl
# Class.<function-name>(args...)
ParasitMath = importClass("java.lang.Math")
println(ParasitMath.sin(pi/2))
```

## How to call an object function

```jl
# obj.<function-name>(args...)
ParasitString = importClass("java.lang.String")
str = @new ParasitString "  hello world!"
str.trim()
```

[Documentation](http://web.mit.edu/julia_v0.6.2/julia/share/doc/julia/html/en/index.html)

[Reflection](https://juliainterop.github.io/JavaCall.jl/reflection.html)