struct IntrospectableFunction
	name
	parameters
	body
	native_function
end

(f::IntrospectableFunction)(x...) = f.native_function(x...)

macro introspectable(form)
	let name = form.args[1].args[1],
		parameters = form.args[1].args[2:end],
		body = form.args[2]
	esc(:($(name) =
		IntrospectableFunction(
			$(QuoteNode(name)),
			$((parameters...,)),
			$(QuoteNode(body)),
			($(parameters...),) -> $body
		)
	))
	end
end
