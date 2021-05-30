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

function importLib(jLib)

	l = listmethods(jlMath)
	mathLib = Dict()

	for i = 1:size(l)[1]

		argstypes = tuple()
		for j = 1:size(getparametertypes(l[i]))[1]
			argstypes = tuple(argstypes..., "j"*getname(getparametertypes(l[i])[j]))
		end

		merge!(mathLib, Dict(
			Meta.parse(getname(l[i])) => (jtr) ->
				(args...) -> JavaValue(jcall(jtr, getname(l[i]), "j"*getname(getreturntype(l[i])), argstypes, args), mathLib)
		))
	end

	# println(getreturntype(l[1]), typeof(getreturntype(l[1])))

	return JavaValue(jlMath(()), mathLib)
end

jlMath = @jimport java.lang.Math
lib = importLib(jlMath)

lib.abs(-15)
