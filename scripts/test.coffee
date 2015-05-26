traversibles = ['body','expression','consequent','alternate','cases','init','test','update','declarations','left','right','handler','guardedHandlers','finalizer','argument','discriminant','callee','arguments','elements','properties']

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

window.check_code = (string, {must_have, mustnt_have, code_structure}) ->
	must_have ||= []
	mustnt_have ||= []
	structure_has = JSON.parse code_structure

	parsed = esprima.parse string
	must_has = []
	mustnt_has = []

	visit_node = (node, structure_pointers) ->
		return if node is null

		# check for requirements

		if node.type in mustnt_have and node.type not in mustnt_has
			mustnt_has.push node.type

		if node.type in must_have and node.type not in must_has
			must_has.push node.type

		found_structures = []
		for pointer in structure_pointers
			for structure in pointer
				if node.type is structure.type
					structure.has = true
					found_structures.push structure

		# visit children

		visit_child = (node, key) ->
			child_structure_pointers = []
			child_structure_pointers = child_structure_pointers.concat structure_pointers
			for structure in found_structures
				if key of structure
					child_structure_pointers.push structure[key]

			child = node[key]
			if $.isArray child
				for child_node in child
					visit_node child_node, child_structure_pointers
			else if child
				visit_node child, child_structure_pointers
			undefined

		for traversible in traversibles
			if traversible of node
				visit_child node, traversible
		
		undefined

	for node in parsed.body
		visit_node node, [structure_has]

	must_hasnt = (type for type in must_have when type not in must_has)
	return {must_hasnt, mustnt_has, structure_has, structure_match:has_all_structures(structure_has)}
