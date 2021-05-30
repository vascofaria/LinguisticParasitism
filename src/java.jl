# import Pkg
# Pkg.add("JavaCall")
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
jtReflectionMethods = Dict()

for i = 1:size(l)[1]
	# println("Name: " * getname(l[i]))
	# println("ReturnType: ", getreturntype(l[i]))
	# println("ArgumentsTypes: ", getparametertypes(l[i]))
end

merge!(jtReflectionMethods, Dict(
	getname(l[1]) => (jtr) ->
		(args...) -> JavaValue(jcall(jtr, getname(l[1]), jlReflectionMethod, getparametertypes(l[1]), args), jtReflectionMethods)
))

print(jtReflectionMethods["invoke"](""))

"""

println(jtReflectionMethods)
jtReflectionMethods["invoke"](jtReflectionMethods)()


println("----- Parameter -----")

l = listmethods(jlReflectionParameter)

for i = 1:size(l)[1]
	println(l[i])
end
"""