# include("java.jl")
# include("introspection.jl")

using JavaCall
JavaCall.init(["-Xmx128M"])

struct JavaValue
	ref::JavaObject
	methods::Dict
end

Base.show(io::IO, obj::JavaObject) = print(io, jcall(obj, "toString", JString, ()))
Base.show(io::IO, jv::JavaValue) = show(io, getfield(jv, :ref))
Base.getproperty(jv::JavaValue, sym::Symbol) = getfield(jv, :methods)[sym](getfield(jv, :ref))

types = Dict(
	:boolean => jboolean,
	:char => jchar,
	:int => jint,
	:long => jlong,
	:float => jfloat,
	:double => jdouble,
	Symbol("java.lang.Object") => JObject
)

function importLib(jLib)

	l = listmethods(jlMath)
	mathLib = Dict()

	for i = 1:size(l)[1]

		argstypes = tuple()
		for j = 1:size(getparametertypes(l[i]))[1]
			argstypes = tuple(argstypes..., types[Symbol(getname(getparametertypes(l[i])[j]))])
		end

		merge!(mathLib, Dict(
			Meta.parse(getname(l[i])) => (jtr) ->
				(args...) -> JavaValue(jcall(jtr, getname(l[i]), types[Symbol(getreturntype(l[i]))], argstypes, args), mathLib)
		))
	end

	return JavaValue(jlMath(()), mathLib)
end

jlMath = @jimport java.lang.Math
lib = importLib(jlMath)

# dump(lib.abs(15))
# getproperty(lib, :abs)(-15)

lib.sin(pi/2)