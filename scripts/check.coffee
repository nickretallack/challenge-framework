has_all_structures = (structures) ->
	for structure in structures
		if not structure.has
			return false

		for key,value of structure
			continue if key is 'type'

			result = has_all_structures structure[key]
			if result is false
				return false

	true

window.check_code = (string, {required, banned, code_structure}) ->
	required ||= []
	banned ||= []
	structure_has = JSON.parse code_structure

	parsed = esprima.parse string
	required_found = []
	banned_found = []

	visit_node = (node, structure_pointers) ->
		return if node is null

		# check for requirements

		if node.type in banned and node.type not in banned_found
			banned_found.push node.type

		if node.type in required and node.type not in required_found
			required_found.push node.type

		found_structures = []
		for pointer in structure_pointers
			for structure in pointer
				if node.type is structure.type
					structure.has = true
					found_structures.push structure

		# visit children

		visit_child = (node, key) ->

			# add traversed versions of any relevant structure pointers

			child_structure_pointers = []
			child_structure_pointers = child_structure_pointers.concat structure_pointers
			for structure in found_structures
				if key of structure
					child_structure_pointers.push structure[key]

			# visit children

			child = node[key]
			if child instanceof Array
				for child_node in child
					visit_node child_node, child_structure_pointers
			else if typeof child?.type is 'string'
				visit_node child, child_structure_pointers
			undefined

		# this logic is based on https://github.com/jrajav/esprima-walk/blob/master/esprima-walk.js
		for key,child of node
			if child instanceof Array or typeof child?.type is 'string'
				visit_child node, key
		
		undefined

	for node in parsed.body
		visit_node node, [structure_has]

	required_missing = (type for type in required when type not in required_found)
	return {required_missing, banned_found, structure_has, structure_match:has_all_structures(structure_has)}
