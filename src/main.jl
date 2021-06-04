include("tests.jl")

LocalDate = importClass("java.time.LocalDate")
t = LocalDate.now()
println(t.plusDays(2))

myString = importClass("java.lang.String")

a = @new myString "  hello world!"

println(a.isEmpty())
println(a.trim())
println(a.trim())

# JavaCall.destroy
