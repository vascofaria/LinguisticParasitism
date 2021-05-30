import Pkg
Pkg.add("JavaCall")
using JavaCall
JavaCall.init(["-Xmx128M"])

struct JavaValue
	ref::JavaObject
	methods::Dict
end

Base.show(io::IO, obj::JavaObject) = print(io, jcall(obj, "toString", JString, ()))
Base.show(io::IO, jv::JavaValue) = show(io, getfield(jv, :ref))
Base.getproperty(jv::JavaValue, sym::Symbol) = getfield(jv, :methods)[sym](getfield(jv, :ref))

# Use the reflection lib de Java to extract all the information from a lib
# Then Generate the Dict with the respective module in Julia


jlMath = @jimport java.lang.Math
jtLD = @jimport java.time.LocalDate

jlReflectionMethod = @jimport java.lang.reflect.Method
jlReflectionParameter = @jimport java.lang.reflect.Parameter
jlReflectionTypeVariable = @jimport java.lang.reflect.TypeVariable
jlReflectionInvocationTargetException = @jimport java.lang.reflect.InvocationTargetException

#   functionName, returnType, argumentsTypes, arguments
# jcall(jlMath, "sin", jdouble, (jdouble,), pi/2)

println("----- Method -----")

l = listmethods(jlReflectionMethod)

for i = 1:size(l)[1]
	println(l[i])
end

jtReflectionMethods = Dict()
"""
merge!(jtReflectionMethods, Dict(
	:l[1][1] => (jtr) ->
		() -> JavaValue(jcall(jtr, "getName", jlReflectionMethod, ()), jtReflectionMethods)
))


println(jtReflectionMethods)
jtReflectionMethods["invoke"](jtReflectionMethods)()
"""

println("----- Parameter -----")

l = listmethods(jlReflectionParameter)

for i = 1:size(l)[1]
	println(l[i])
end
