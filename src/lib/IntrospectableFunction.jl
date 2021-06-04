struct IntrospectableFunction
	name
	parameterstypes
	native_function
end

(f::IntrospectableFunction)(x...) = f.native_function(x...)

function (availablemethods::Array{IntrospectableFunction})(args...)
	for i = 1:size(availablemethods)[1]
		if (length(availablemethods[i].parameterstypes) == length(args))

			valid = true

			for j = 1:length(availablemethods[i].parameterstypes)
				# ignore JavaObjects, let Java handle it
				# if the argtype is a subtype of parametertype
				# if the parameter is a primitive type, use the casted value
				if ((availablemethods[i].parameterstypes)[j] != JObject &&
					!(typeof(args[j]) <: (availablemethods[i].parameterstypes)[j]) &&
					!(haskey(_primitivetypes, Symbol((availablemethods[i].parameterstypes)[j])) &&
					(typeof(args[j]) <: _primitivetypes[Symbol((availablemethods[i].parameterstypes)[j])]))
				)
					valid = false
				end
			end

			if (valid)
				return availablemethods[i](args...)
			end
		end
	end
	throw("No such method exist")
end
