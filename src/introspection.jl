struct IntrospectableFunction
	name
	parameters
	native_function
end

(f::IntrospectableFunction)(x...) = f.native_function(x...)

