# find_missing_structures = (structure) ->
	
window.check_code = (string, {must_have, mustnt_have, code_structure}) ->
	must_have ||= []
	mustnt_have ||= []
	structure_has = JSON.parse code_structure

	parsed = esprima.parse string
	console.log parsed
	must_has = []
	mustnt_has = []
	# structure_has = $.extend true, [], structures
	# structure_has =  # todo: copy the structure so we can mess with it non-i

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
			child_structures_pointers = child_structure_pointers.concat structure_pointers
			for structure in found_structures
				if key of structure
					child_structures_pointers = child_structure_pointers.concat structure[key]

			child = node[key]
			if $.isArray child
				for child_node in child
					visit_node child_node, child_structure_pointers
			else if child
				visit_node child, child_structure_pointers
			undefined

		if node.type is 'IfStatement'
			visit_child node, 'consequent'
			visit_child node, 'alternate'

		if node.body?
			visit_child node, 'body'
		
		undefined

	for node in parsed.body
		visit_node node, [structure_has]

	must_hasnt = (type for type in must_have when type not in must_has)
	console.log structure_has
	return {must_hasnt, mustnt_has, structure_has}

snippet = """
 var y = 5;
 if(y){
 	for(x=0; x<5; x++){
 		console.log('yay')
 	}
 }
 """

# console.log test snippet,
# 	must_have:['IfStatement']
# 	mustnt_have:['WhileStatement']
# 	structure:[{type: 'IfStatement', consequent: {type:'ForStatement'}}]