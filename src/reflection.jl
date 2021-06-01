# import Pkg
# Pkg.add("JavaCall")
using JavaCall
JavaCall.init(["-Xmx128M"])

jlReflectionMethod = @jimport java.lang.reflect.Method
jlReflectionParameter = @jimport java.lang.reflect.Parameter
jlReflectionTypeVariable = @jimport java.lang.reflect.TypeVariable
jlReflectionInvocationTargetException = @jimport java.lang.reflect.InvocationTargetException

