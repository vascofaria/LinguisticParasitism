# import Pkg
# Pkg.add("JavaCall")
using JavaCall
JavaCall.init(["-Xmx128M"])

struct JavaValue
	ref::JavaObject
	methods::Dict{}
end

function Base.getproperty(obj::JavaValue, sym::Symbol)
	if (haskey(getfield(obj, :methods), sym))
		# Methods with diff parameters will fail
		# We need to create a Dcit of Arrays to know the parameters types
		return getfield(obj, :methods)[sym]
	else
		# create new method
		newmethod = invoke(getfield(obj, :ref), string(sym), args)
		return newmethod
	end
	return getfield(obj, :ref)[sym]
end

"""
ld = LocalDate.now()

ld = ld.plusYears(2)
ld = ld.plusYears(2.0)
"""

Methods = Dict(
	:plusYears => [x -> println(1 * x), x -> println(1 + x)],
	:ola => []
)


# ld.plusYears(2) => importar todos os plusYears
# ld.plusYears(2.0)

struct JtoJType
	types::Dict{Symbol, DataType}
end

Base.getproperty(obj::JtoJType, sym::Symbol) = getfield(obj, :types)[sym]

_types = Dict(
	:boolean => jboolean,
	:char => jchar,
	:int => jint,
	:long => jlong,
	:float => jfloat,
	:double => jdouble
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
			if parametertypes[j] != argstypes[j] # TODO Use isAssignableFrom
				break
			end
		end
		return l[i]
	end
	
	throw(MethodError(e, "Method Does not exist."))
end

function getParameterTypes(method)
	parameterstypes = tuple()
	for j = 1:size(getparametertypes(method))[1]

		if (!haskey(_types, Symbol(getname(getparametertypes(method)[j]))))
			importClass(getname(getparametertypes(method)[j]))
		end

		parameterstypes = tuple(parameterstypes..., _types[Symbol(getname(getparametertypes(method)[j]))])
	end
	return parameterstypes
end

function getReturnType(method)

	if (!haskey(_types, Symbol(getname(getreturntype(method)))))
		importClass(getname(getreturntype(method)))
	end

	return _types[Symbol(getname(getreturntype(method)))]
end

function invoke(receiver, name, args...)
	# TODO import lib, with lazy
	try
		argstypes = getArgumentsTypes(args)
		
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

function importClass(className)
	# println("Importing: ", className)
	merge!(_types, Dict(
		Symbol(className) => JavaObject{Symbol(className)}
	))
	return JavaObject{Symbol(className)}
end

"""
importClass("java.lang.Class")
ldate = importClass("java.time.LocalDate")
object = importClass("java.lang.Object")
c1 = jcall(ldate, "getClass", JObject, ())
c2 = jcall(object, "getClass", JObject, ())
println(c1, c2)
show(jcall(ldate, "isAssignableFrom", jboolean, (JObject,), object))
"""

"""
LocalDate = importClass("java.time.LocalDate")
instance = invoke(LocalDate, "now")

show(invoke(instance, "plusYears", 3))
instance = invoke(instance, "plusYears", 3)
show(invoke(instance, "plusWeeks", 3))
show(invoke(instance, "plusDays", 3))

importClass("java.lang.Integer")
jlMath = importClass("java.lang.Math")
println(invoke(jlMath, "sin", pi/2))

"""

# importClass("java.lang.CharSequence")
jlString = importClass("java.lang.String")
instance = jlString("asd")
println(invoke(instance, "isEmpty"))


# TODO Arrays

# Base.getproperty(obj::JavaObject, sym::Symbol) = invoke(obj, sym)[sym](getfield(jv, :ref))
# Base.getproperty(dict::Dict{Symbol, DataType}, sym::Symbol) = dict[sym]

# JavaCall.destroy
