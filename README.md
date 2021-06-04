# LinguisticParasitism
Group 9 - Advanced Programming 20/21

## Run in Linux:

```sh
export JULIA_COPY_STACKS=1
cd src/
julia main.jl
```

# Usage

## How to import our lib

```jl
include("lib/JavaParasite.jl")
```

## How to import a Java Class

```jl
# importClass(className)
ParasiteString = importClass("java.lang.String")
```

## How to create an instance of the class

```jl
# @new Class arg1 arg2 ...
str = @new ParasiteString "  hello world!"
```

## How to call a static function

```jl
# Class.<function-name>(args...)
ParasiteMath = importClass("java.lang.Math")
ParasiteMath.sin(pi/2)
```

## How to call an object function

```jl
# obj.<function-name>(args...)
ParasiteString = importClass("java.lang.String")
str = @new ParasiteString "  hello world!"
str.trim()
```

[Documentation](http://web.mit.edu/julia_v0.6.2/julia/share/doc/julia/html/en/index.html)

[Reflection](https://juliainterop.github.io/JavaCall.jl/reflection.html)