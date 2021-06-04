# import Pkg
# Pkg.add("JavaCall")
include("lib/JavaParasit.jl")

ParasitLocalDate = importClass("java.time.LocalDate")
t = ParasitLocalDate.now()
println(t.plusDays(2))

ParasitMath = importClass("java.lang.Math")
println(ParasitMath.sin(pi/2))

ParasitString = importClass("java.lang.String")
str = @new ParasitString "  hello world!"
if (!str.isEmpty())
	str = str.trim().replace('l', 'w')
	println(str)
end

ParasitHashMap = importClass("java.util.HashMap")
hm = @new ParasitHashMap
hm.put("foo", "text value")
println(hm.get("foo"))

# JavaCall.destroy
