using Base: Symbol
# import Pkg
# Pkg.add("JavaCall")
using JavaCall
JavaCall.init(["-Xmx128M"])

types = Dict(
	:boolean => jboolean,
	:char => jchar,
	:int => jint,
	:long => jlong,
	:float => jfloat,
	:double => jdouble# ,
	# Symbol("java.lang.Object") => JObject,
	# Symbol("java.lang.String") => JString
)

function getArgumentsTypes(args)
	argstypes = tuple()
	for i = 1:length(args)
		argstypes = tuple(argstypes..., typeof(args[i]))
	end
	return argstypes
end

function getAvailableMethods(receiver, name, argstypes)
	l = listmethods(receiver, name)

	for i = 1:size(l)[1]
		parametertypes = getParameterTypes(l[i])
		for j = 1:length(parametertypes)
			#println(parametertypes[j], argstypes[j])
			if parametertypes[j] != argstypes[j]
				break
			end
		end
		return l[i]
	end
	
	throw(MethodError(e, "METHODS DOESNT EXIST"))
end

function getParameterTypes(method)
	parameterstypes = tuple()
	for j = 1:size(getparametertypes(method))[1]
		parameterstypes = tuple(parameterstypes..., types[Symbol(getname(getparametertypes(method)[j]))])
	end
	return parameterstypes
end

function getReturnType(method)
	return types[Symbol(getname(getreturntype(method)))]
end

function invoke(receiver, name, args...)
	try
		argstypes = getArgumentsTypes(args)

		#println(receiver)
		#println(name)
		#println(args)
		#println(argstypes)
		
		method = getAvailableMethods(receiver, name, argstypes)

		parameterstypes = getParameterTypes(method)

		returntype = getReturnType(method)

		convertedargs = tuple()
		for i = 1:length(args)
			convertedargs = tuple(convertedargs..., convert(parameterstypes[i], args[i]))
		end

		return jcall(receiver, getname(method), returntype, parameterstypes, convertedargs...)

	catch e
		println("ERROR: ", e)
	end
end


Base.show(io::IO, obj::JavaObject) = println(io, jcall(obj, "toString", JString, ()))
# Base.getproperty(obj::JavaObject, sym::Symbol) = invoke(obj, sym)[sym](getfield(jv, :ref))
# Base.getproperty(dict::Dict, sym::Symbol) = dict[sym]

function importClass(className)
	# println(narrow(JavaObject{Symbol(className)}))
	merge!(types, Dict(
		Symbol(className) => JavaObject{Symbol(className)}
	))
	return JavaObject{Symbol(className)}
end

"""
jtLD = importClass("java.time.LocalDate")

println(types)
local_date_now() = jcall(jtLD, "now", jtLD, ())
instance = local_date_now()
show(invoke(instance, "plusYears", 3))
"""

importClass("java.lang.Integer")
jlMath = importClass("java.lang.Math")
println(invoke(jlMath, "sin", pi/2))

#println(types.int)

"""
jlString = importClass("java.lang.String")

# jlString = @jimport java.lang.String

println(types)

instance = jlString("asd")

println(getname(getclass(instance)))

println(invoke(instance, "split", "a", 1))
"""



# JavaCall.destroy
