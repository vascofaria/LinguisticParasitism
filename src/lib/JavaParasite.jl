using JavaCall
JavaCall.init(["-Xmx128M"])

include("IntrospectableFunction.jl")

struct JavaValue
	ref::Any
	methods::Dict{Symbol, Array{IntrospectableFunction}}
end

Base.show(io::IO, obj::JavaObject) = print(io, jcall(obj, "toString", JString, ()))
Base.show(io::IO, obj::JavaValue) = print(io, jcall(getfield(obj, :ref), "toString", JString, ()))

# Call JavaValue ref (Class) constructor
# Returns a JavaValue with ref instanciated
macro new(cls, args...)
	ref = getfield(eval(cls), :ref)(args...)
	return :( JavaValue($ref, Dict()) )
end

# Return Primitive Types Cast
_primitivetypes = Dict(
	:UInt8 => Bool,
	:UInt16 => Char,
	:Int32 => jint,
	:Int64 => jlong,
	:Float32 => jfloat,
	:Float64 => jdouble
)

# Java Types Cast
_types = Dict(
	:boolean => jboolean,
	:char => jchar,
	:int => jint,
	:long => jlong,
	:float => jfloat,
	:double => jdouble
)

# Adds a new JavaType to _types dictionary
function importClass(className)
	merge!(_types, Dict(
		Symbol(className) => JavaObject{Symbol(className)}
	))
	return JavaValue(JavaObject{Symbol(className)}, Dict())
end

# Creates a tuple of arguments types
function getArgumentsTypes(args)
	argstypes = tuple()
	for i = 1:length(args)
		argstypes = tuple(argstypes..., typeof(args[i]))
	end
	return argstypes
end

# Creates a tuple of the method parameters types
function getParameterTypes(method)
	parameterstypes = tuple()
	for j = 1:size(getparametertypes(method))[1]

		# if it is a new type, automatically import it
		if (!haskey(_types, Symbol(getname(getparametertypes(method)[j]))))
			importClass(getname(getparametertypes(method)[j]))
		end

		parameterstypes = tuple(parameterstypes..., _types[Symbol(getname(getparametertypes(method)[j]))])
	end
	return parameterstypes
end

# Extracts method return type
function getReturnType(method)

	if (!haskey(_types, Symbol(getname(getreturntype(method)))))
		importClass(getname(getreturntype(method)))
	end

	return _types[Symbol(getname(getreturntype(method)))]
end

# Imports all the methods with a given name and cache them into the receiver (Class/Object)
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
		println("(Error) importMethods: ", e)
		throw(e)
	end
end

# Reprogram getproperty behavior of JavaValue
function Base.getproperty(obj::JavaValue, sym::Symbol)
	# if the object has the method cached, call it
	if (haskey(getfield(obj, :methods), sym))
		return getfield(obj, :methods)[sym]
	else
		# else import methods with that name
		try
			importMethods(obj, string(sym))
			if (haskey(getfield(obj, :methods), sym) && size(getfield(obj, :methods)[sym])[1] > 0)
				return getfield(obj, :methods)[sym]
			else
				throw("No such method exist")
			end
		catch e
			println("(Error) Base.getproperty(obj::JavaValue, sym::Symbol)", e)
			throw(e)
		end
	end
end

