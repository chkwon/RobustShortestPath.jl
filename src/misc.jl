function create_graph(start_node, end_node, link_length)
	@assert length(start_node)==length(end_node)

	no_node = max(maximum(start_node), maximum(end_node))
	no_arc = length(start_node)

	graph = Graph(no_node)
	distmx = Inf*ones(no_node, no_node)
	for i=1:no_arc
		add_edge!(graph, start_node[i], end_node[i])
		distmx[start_node[i], end_node[i]] = link_length[i]
	end
	return graph, distmx
end

function get_shortest_path(start_node::Array, end_node::Array, link_length::Array, origin::Int, destination::Int)
	@assert length(start_node)==length(end_node)
	@assert length(start_node)==length(link_length)

	graph, distmx = create_graph(start_node, end_node, link_length)

	state = dijkstra_shortest_paths(graph, origin, distmx)

	path = get_path(state, origin, destination)
	x = get_vector(path, start_node, end_node)

	len = state.dists[destination]

	return path, x, len
end

function get_path(state, origin, destination)
	_current = destination
	_rpath = _current
	_parent = -1

	while _parent != origin
		_parent = state.parents[_current]
		_rpath = [_rpath; _parent]
		_current = _parent
	end

	_path = zeros(Int, length(_rpath))
	for i=length(_rpath):-1:1
		_path[length(_rpath)-i+1] = _rpath[i]
	end
	return _path
end

function get_vector(path, start_node, end_node)
	x = zeros(Int, length(start_node))

	for i=1:length(path)-1
		st = path[i]
		en = path[i+1]

		for j=1:length(start_node)
			if start_node[j]==st && end_node[j]==en
				x[j] = 1
				break
			end
		end

	end
	return x
end
