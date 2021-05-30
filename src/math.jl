using JavaCall
JavaCall.init(["-Xmx128M"])

struct JavaValue
	ref::JavaObject
	methods::Dict
end

Base.show(io::IO, obj::JavaObject) = print(io, jcall(obj, "toString", JString, ()))
Base.show(io::IO, jv::JavaValue) = show(io, getfield(jv, :ref))
Base.getproperty(jv::JavaValue, sym::Symbol) = getfield(jv, :methods)[sym](getfield(jv, :ref))

jlMath = @jimport java.lang.Math

l = listmethods(jlMath)
mathLib = Dict()

# mathTuple = tuple()

for i = 1:size(l)[1]
	merge!(mathLib, Dict(
		Meta.parse(getname(l[i])) => (jtr) ->
			(args...) -> JavaValue(jcall(jtr, getname(l[i]), getreturntype(l[i]), getparametertypes(l[i]), args), mathLib)
	))
	# mathTuple = tuple(mathTuple..., 
	# 	x = (args...) -> jcall(jlMath, getname(l[i]), getreturntype(l[i]), getparametertypes(l[i]), args)
	# )
end

# show(mathLib)



math = JavaValue(jlMath(()), mathLib)

show(getfield(math, :methods)[:abs](jlMath)(-15))

#show(math.abs(-15))

