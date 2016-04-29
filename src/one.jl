

function get_robust_path(start_node::Array, end_node::Array, c::Array, d::Array, Gamma, origin, destination)
	@assert length(start_node)==length(end_node)
	@assert length(start_node)==length(c)
	@assert length(start_node)==length(d)

	no_arc = length(start_node)

	dset = [sort(d, rev=true); 0]
	best_obj = Inf
	best_path = []
	best_x = []

	# Constructing Lset as in Lee and Kwon (2014) http://dx.doi.org/10.1007/s10288-014-0270-7
	k_max = round(Int, ceil((no_arc - Gamma)/2))

	Lset = Array{Int}(k_max+1)
	for k=1:k_max
		Lset[k] = Gamma + 2*k-1
	end
	Lset[k_max+1]=no_arc + 1

	# This for-loop examines the smallest theta first.
	for i=length(Lset):-1:1
		theta = dset[Lset[i]]
		link_cost = c + max(d - theta, 0)

		# println("$i : $theta : $(Gamma*theta) : $best_obj")

		if Gamma*theta > best_obj
			# If this condition is true, next theta values will always have a bigger objective value.
			# We can stop examining theta values.
			break
		end

		(pp, xx, ll) = get_shortest_path(start_node, end_node, link_cost, origin, destination)
		# current_obj = Gamma * theta + dot(link_cost, xx)
		current_obj = Gamma * theta + ll

		if current_obj < best_obj
			best_obj = current_obj
			best_path = pp
			best_x = xx
		end

	end

	return best_path, best_x, best_obj
end
