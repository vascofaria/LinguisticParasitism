# import Pkg
# Pkg.add("JavaCall")
using JavaCall
JavaCall.init(["-Xmx128M"])

include("introspection.jl")

struct JavaValue
	ref::Any
	methods::Dict{Symbol, Array{IntrospectableFunction}}
end

function Base.getproperty(obj::JavaValue, sym::Symbol)
	if (haskey(getfield(obj, :methods), sym))
		# Methods with diff parameters will fail
		# We need to create a Dcit of Arrays to know the parameters types
		return getfield(obj, :methods)[sym][1] # TODO choose by parameters
	else
		# create new method
		try
			importMethods(obj, string(sym))
			if (haskey(getfield(obj, :methods), sym))
				return getfield(obj, :methods)[sym][1]
			else
				throw("No such method exist")
			end
		catch e
			println("getproperty: ", e)
			throw(e)
		end
	end
	# return getfield(obj, :ref)[sym]
end

"""
ld = LocalDate.now()

ld = ld.plusYears(2)
ld = ld.plusYears(2.0)


Methods = Dict(
	:plusYears => [x -> println(1 * x), x -> println(1 + x)],
	:ola => []
)
@introspectable fahrenheit_from_centigrade(c) = c*9/5 + 32.0

println(fahrenheit_from_centigrade(36.5))

# ld.plusYears(2) => importar todos os plusYears
# ld.plusYears(2.0)
"""

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

function importMethods(receiver::JavaValue, name)
	# TODO import lib, with lazy
	try
		# argstypes = getArgumentsTypes(args)
		
		# method = getAvailableMethods(receiver, name, argstypes)

		# parameterstypes = getParameterTypes(method)

		# returntype = getReturnType(method)

		availablemethods = listmethods(getfield(receiver, :ref), name)

		merge!(getfield(receiver, :methods), Dict(
			Symbol(name) => Vector{IntrospectableFunction}()
		))

		for i = 1:size(availablemethods)[1]

			parameterstypes = getParameterTypes(availablemethods[i])
			returntype = getReturnType(availablemethods[i])

			push!(
				getfield(receiver, :methods)[Symbol(name)],
					IntrospectableFunction(
						Symbol(name),
						parameterstypes,
						(args...) -> begin
							convertedargs = tuple()
							for j = 1:length(args)
								convertedargs = tuple(convertedargs..., convert(parameterstypes[j], args[j]))
							end
							return JavaValue(jcall(getfield(receiver, :ref), name, returntype, parameterstypes, convertedargs...), Dict())
						end
					)
			)
		end

	catch e
		println("ERROR: ", e)
	end
end

Base.show(io::IO, obj::JavaObject) = print(io, jcall(obj, "toString", JString, ()))
Base.show(io::IO, obj::JavaValue) = print(io, jcall(getfield(obj, :ref), "toString", JString, ()))

function importClass(className)
	# println("Importing: ", className)
	merge!(_types, Dict(
		Symbol(className) => JavaObject{Symbol(className)}
	))
	return JavaValue(JavaObject{Symbol(className)}, Dict())
end

"""
LocalDate = importClass("java.time.LocalDate")

merge!(getfield(LocalDate, :methods), Dict(
	Symbol("now") => Vector{IntrospectableFunction}()
))

m = listmethods(getfield(LocalDate, :ref), "now")[1]


f = IntrospectableFunction(
	"now",
	getParameterTypes(m),
	(args...) -> println(args)
)

push!(
	getfield(LocalDate, :methods)[:now],
	f
)

println(LocalDate)
"""

LocalDate = importClass("java.time.LocalDate")

t = LocalDate.now()
println(t.plusDays(2))

myString = importClass("java.lang.String")

# s = JavaValue(getfield(myString, :ref)(""), Dict())
println(getfield(myString, :ref)(()))

# println(s.isEmpty())

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


# importClass("java.lang.CharSequence")
jlString = importClass("java.lang.String")
instance = jlString("asd")
println(getname(getclass(instance)))
println(invoke(instance, "replace", "a", "b"))
"""
# TODO Arrays

# Base.getproperty(obj::JavaObject, sym::Symbol) = invoke(obj, sym)[sym](getfield(jv, :ref))
# Base.getproperty(dict::Dict{Symbol, DataType}, sym::Symbol) = dict[sym]

# JavaCall.destroy
