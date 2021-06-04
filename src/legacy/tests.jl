# import Pkg
# Pkg.add("JavaCall")
using JavaCall
JavaCall.init(["-Xmx128M"])

include("IntrospectableFunction.jl")

struct JavaValue
	ref::Any
	methods::Dict{Symbol, Array{IntrospectableFunction}}
end

Base.show(io::IO, obj::JavaObject) = print(io, jcall(obj, "toString", JString, ()))
Base.show(io::IO, obj::JavaValue) = print(io, jcall(getfield(obj, :ref), "toString", JString, ()))

macro new(args...)
	cls = eval(args[1])
	targs = tuple()
	for i = 2:length(args)
		targs = tuple(targs..., eval(args[i]))
	end
	ref = getfield(cls, :ref)(targs...)
	obj = JavaValue(ref, Dict())
	return :( JavaValue($ref, Dict()) )
end

function importClass(className)
	merge!(_types, Dict(
		Symbol(className) => JavaObject{Symbol(className)}
	))
	return JavaValue(JavaObject{Symbol(className)}, Dict())
end

function Base.getproperty(obj::JavaValue, sym::Symbol)
	if (haskey(getfield(obj, :methods), sym))
		return getfield(obj, :methods)[sym]
	else
		# create new method
		try
			importMethods(obj, string(sym))
			if (haskey(getfield(obj, :methods), sym) && size(getfield(obj, :methods)[sym])[1] > 0)

				return getfield(obj, :methods)[sym]
			else
				throw("No such method exist")
			end
		catch e
			throw(e)
		end
	end
end

_primitivetypes = Dict(
	:UInt8 => Bool,
	:Uint16 => Char,
	:Int32 => jint,
	:Int64 => jlong,
	:Float32 => jfloat,
	:Float64 => jdouble
)

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
	try
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
							r = getfield(receiver, :ref)
							cll = jcall(r, name, returntype, parameterstypes, convertedargs...)

							# if return type is primitive
							if (haskey(_primitivetypes, Symbol(typeof(cll))))
								return convert(_primitivetypes[Symbol(typeof(cll))], cll)
							# if receiver is a Class
							elseif (typeof(getfield(receiver, :ref)) == DataType)
								return JavaValue(cll, Dict())
							end
							# if returntype is an object
							return JavaValue(convert(returntype, cll), Dict())
						end
					)
			)
		end

	catch e
		println("ERROR: ", e)
	end
end

"""
LocalDate = importClass("java.time.LocalDate")
t = LocalDate.now()
println(t.plusDays(2))

myString = importClass("java.lang.String")

a = @new myString "  hello world   !"

println(a.isEmpty())
println(a.trim())
println(a.trim())

# JavaCall.destroy
"""
