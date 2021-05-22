import Pkg

Pkg.add("JavaCall")

using JavaCall

JavaCall.init(["-Xmx128M"])

jlM = @jimport java.lang.Math


#   functionName, returnType, argumentsTypes, arguments
jcall(jlM, "sin", jdouble, (jdouble,), pi/2)


jsin(x) = jcall(jlM, "sin", jdouble, (jdouble,), x)

jsin(pi/2)

Math = (
	sin = x -> jcall(jlM, "sin", jdouble, (jdouble,), x),
	cos = x -> jcall(jlM, "cos", jdouble, (jdouble,), x)
)

Math.cos(pi)

jtLD = @jimport java.time.LocalDate

local_date_now() = jcall(jtLD, "now", jtLD, ())

Base.show(io::IO, obj::JavaObject) = print(io, jcall(obj, "toString", JString, ()))

show(local_date_now())

plus_days(jld, days) = jcall(jld, "plusDays", jtLD, (jlong,), days)

show(plus_days(local_date_now(), 4))

struct JavaValue
	ref::JavaObject
	methods::Dict
end

Base.show(io::IO, jv::JavaValue) = show(io, getfield(jv, :ref))

Base.getproperty(jv::JavaValue, sym::Symbol) = getfield(jv, :methods)[sym](getfield(jv, :ref))

jtLDMethods = Dict(
	:plusDays => (jtld) ->
		(days) ->
			JavaValue(jcall(jtld, "plusDays", jtLD, (jlong,), days), jtLDMethods),
	:plusMonths => (jtld) ->
		(months) -> 
			JavaValue(jcall(jtld, "plusMonths", jtLD, (jlong,), months), jtLDMethods),
	:plusWeeks => (jtld) ->
		(weeks) -> 
			JavaValue(jcall(jtld, "plusWeeks", jtLD, (jlong,), weeks), jtLDMethods),
	:plusYears => (jtld) ->
		(years) -> 
			JavaValue(jcall(jtld, "plusYears", jtLD, (jlong,), years), jtLDMethods)
)

now = JavaValue(local_date_now(), jtLDMethods)

show(now.plusDays(4))
