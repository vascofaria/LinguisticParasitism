# import Pkg
# Pkg.add("JavaCall")
include("lib/JavaParasite.jl")

ParasiteLocalDate = importClass("java.time.LocalDate")
t = ParasiteLocalDate.now()
println(t.plusDays(2))

ParasiteMath = importClass("java.lang.Math")
println(ParasiteMath.sin(pi/2))

ParasiteString = importClass("java.lang.String")
str = @new ParasiteString "  hello world!"
if (!str.isEmpty())
	str = str.trim().replace('l', 'w')
	println(str)
end

ParasiteHashMap = importClass("java.util.HashMap")
hm = @new ParasiteHashMap
hm.put("foo", "text value")
println(hm.get("foo"))

# JavaCall.destroy
