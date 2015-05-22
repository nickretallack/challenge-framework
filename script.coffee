test = (string, {must_have, mustnt_have, structures}) ->
	must_have ||= []
	mustnt_have ||= []
	structures ||= []

	parsed = esprima.parse string
	console.log parsed
	must_has = []
	mustnt_has = []

	visit_node = (node) ->
		return if node is null

		if node.type in mustnt_have and node.type not in mustnt_has
			mustnt_has.push node.type

		if node.type in must_have and node.type not in must_has
			console.log "has", node.type
			must_has.push node.type

		if node.type is 'IfStatement'
			visit_node node.consequent
			visit_node node.alternate

		if node.body?
			for child_node in node.body
				visit_node child_node
		undefined

	for node in parsed.body
		visit_node node

	must_hasnt = (type for type in must_have when type not in must_has)
	return {must_hasnt, mustnt_has}

snippet = """
var y = 5;
if(y){
	for(x=0; x<5; x++){
		console.log('yay')
	}
}
"""

console.log test snippet,
	must_have:['IfStatement']
	mustnt_have:['WhileStatement']