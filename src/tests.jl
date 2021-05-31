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

function getAvailableMethods(receiver, name, argstypes)
	return listmethods(receiver, name)[1]
end

function invoke(receiver, name, class::Type, args...)
	try
		argstypes = tuple()
		for i = 1:length(args)
			argstypes = tuple(argstypes..., typeof(args[i]))
		end
		
		method = getAvailableMethods(receiver, name, argstypes)

		parameterstypes = tuple()
		for j = 1:size(getparametertypes(method))[1]
			parameterstypes = tuple(parameterstypes..., types[Symbol(getname(getparametertypes(method)[j]))])
		end

		# returntype = types[Symbol(getname(getreturntype(method)))]
		returntype = class

		convertedargs = tuple()
		for i = 1:length(args)
			convertedargs = tuple(convertedargs..., convert(parameterstypes[i], args[i]))
		end

		return jcall(receiver, getname(method), returntype, parameterstypes, convertedargs...)

	catch e
		println("ERROR: ", e)
	end
end

function invoke(class, name, args...)
	try
		argstypes = tuple()
		for i = 1:length(args)
			argstypes = tuple(argstypes..., typeof(args[i]))
		end
		
		method = getAvailableMethods(class, name, argstypes)

		parameterstypes = tuple()
		for j = 1:size(getparametertypes(method))[1]
			parameterstypes = tuple(parameterstypes..., types[Symbol(getname(getparametertypes(method)[j]))])
		end

		returntype = types[Symbol(getname(getreturntype(method)))]

		convertedargs = tuple()
		for i = 1:length(args)
			convertedargs = tuple(convertedargs..., convert(parameterstypes[i], args[i]))
		end

		return jcall(class, getname(method), returntype, parameterstypes, convertedargs...)

	catch e
		println("ERROR: ", e)
	end
end

Base.show(io::IO, obj::JavaObject) = println(io, jcall(obj, "toString", JString, ()))
# Base.getproperty(obj::JavaObject, sym::Symbol) = invoke(obj, sym)[sym](getfield(jv, :ref))

jtLD = @jimport java.time.LocalDate
local_date_now() = jcall(jtLD, "now", jtLD, ())
instance = local_date_now()
show(invoke(instance, "plusDays", jtLD, 3))

jlMath = @jimport java.lang.Math
class = jlMath
println(invoke(class, "sin", pi/2))

jlString = @jimport java.lang.String
instance = jlString((""))
println(invoke(instance, "isEmpty"))

instance.isEmpty()