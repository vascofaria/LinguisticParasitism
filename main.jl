# import Pkg
# Pkg.add("JavaCall")
include("lib/JavaParasit.jl")

LocalDate = importClass("java.time.LocalDate")
t = LocalDate.now()
println(t.plusDays(2))

myString = importClass("java.lang.String")

a = @new myString "  hello world!"

println(a.isEmpty())
println(a.trim())
println(a.trim())
println(a.replace('l', 'o'))

HashMap = importClass("java.util.HashMap")
hm = @new HashMap
hm.put("foo", "text value")
println(hm.get("foo"))

# JavaCall.destroy
