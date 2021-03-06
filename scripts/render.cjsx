display_names =
	# control structures
	IfStatement: "If Statement"
	SwitchStatement: "Switch Statement"

	WhileStatement: "While Loop"
	DoWhileStatement: "Do While Loop"

	ForStatement: "For Loop"
	ForInStatement: "For In Loop"
	ForOfStatement: "For Of Loop"

	TryStatement: "Try"
	ThrowStatement: "Throw"

	ReturnStatement: "Return"
	BreakStatement: "Break"
	ContinueStatement: "Continue"

	# common things
	ExpressionStatement: "Expression Statement"
	CallExpression: "Function Call"
	MemberExpression: "Property Access"

	# declarations and assignments
	VariableDeclaration: "Variable Declaration"
	FunctionDeclaration: "Function Declaration"
	FunctionExpression: "Function Expression"
	AssignmentExpression: "Assignment Expression"
	ArrayExpression: "Array Expression"
	ObjectExpression: "Object Expression"
	Literal: "Literal"

	# Operator Types
	BinaryExpression: "Binary Operator"
	UnaryExpression: "Unary Operator"
	LogicalExpression: "Logical Operator"
	UpdateExpression: "Update Operator"
	ConditionalExpression: "Ternary Operator"

	# objects
	NewExpression: "New"
	ThisExpression: "This"

	# New stuff
	ArrowExpression: "Fat Arrow"
	ObjectPattern: "Object Pattern"
	ArrayPattern: "Array Pattern"

	# rarely used / barely relevant
	WithStatement: "With Statement"
	LabeledStatement: "Label"
	DebuggerStatement: "Debug"
	SequenceExpression: "Commas"


structure_types = (key for key of display_names)


CodeEditor = React.createClass
	displayName: "CodeEditor"

	componentDidMount: ->
		editor = ace.edit @refs.text.getDOMNode()
		editor.$blockScrolling = Infinity
		session = editor.getSession()
		session.setValue @props.code.val()
		session.setMode @props.mode or "ace/mode/javascript"
		@setState session: session
		session.on 'change', =>
			@props.code.set session.getValue()

	render: ->
		<div ref="text" style={height:@props.height}></div>


MustHave = React.createClass
	displayName: "MustHave"

	render: ->
		name = display_names[@props.value] or @props.value
		if @props.ok
			<li className="good">
				<span className="glyphicon glyphicon-ok" aria-hidden="true"></span> {name}
			</li>
		else if @props.ok is false
			<li className="bad">
				<span className="glyphicon glyphicon-remove" aria-hidden="true"></span> {name}
			</li>
		else
			<li className="unknown">
				<span className="glyphicon glyphicon-question-sign" aria-hidden="true"></span> {name}
			</li>


Feedback = React.createClass
	displayName: "Feedback"

	render: ->
		if @props.feedback.error
			error = <div className="bad"><span className="glyphicon glyphicon-remove" aria-hidden="true"></span> {@props.feedback.error.toString()}</div>

			required_structures = @props.requirements.required.val()
			required = if required_structures.length
				required_nodes = for structure_type in required_structures
					<MustHave value={structure_type} ok={null} key={structure_type}/>

				<div>
					Your solution must have:
					<ul className="list-unstyled">{required_nodes}</ul>
				</div>

			banned_structures = @props.requirements.banned.val()
			banned = if banned_structures.length
				banned_nodes = for structure_type in banned_structures
					<MustHave value={structure_type} ok={null} key={structure_type}/>

				<div>
					Your solution must not have:
					<ul className="list-unstyled">{banned_nodes}</ul>
				</div>

			<div>
				<p>{@props.assignment_text.val()}</p>
				{required}
				{banned}
				{error}
			</div>

		else
			required_structures = @props.requirements.required.val()
			required = if required_structures.length
				required_missing = @props.feedback.required_missing
				required_nodes = for structure_type in required_structures
					ok = structure_type not in required_missing
					<MustHave value={structure_type} ok={ok} key={structure_type}/>

				<div>
					Your solution must have:
					<ul className="list-unstyled">{required_nodes}</ul>
				</div>

			banned_structures = @props.requirements.banned.val()
			banned = if banned_structures.length
				banned_has = @props.feedback.banned_found
				banned_nodes = for structure_type in banned_structures
					ok = structure_type not in banned_has
					<MustHave value={structure_type} ok={ok} key={structure_type}/>

				<div>
					Your solution must not have:
					<ul className="list-unstyled">{banned_nodes}</ul>
				</div>

			structure_match = if @props.feedback.structure_match
				<MustHave value="Structure matches" ok={true}/>
			else
				<MustHave value="Structure doesn't match" ok={false}/>

			<div>
				<p>{@props.assignment_text.val()}</p>
				{required}
				{banned}
				<ul className="list-unstyled">{structure_match}</ul>
			</div>


RequiredOrBanned = React.createClass
	displayName: "RequiredOrBanned"

	require: ->
		if !@findRequired()
			@props.required.push @props.value
		@findBanned()?.remove()

	ban: ->
		if !@findBanned()
			@props.banned.push @props.value
		@findRequired()?.remove()

	allow: ->
		@findRequired()?.remove()
		@findBanned()?.remove()

	findRequired: ->
		@props.required.find (item) => item.val() == @props.value

	findBanned: ->
		@props.banned.find (item) => item.val() == @props.value

	render: ->
		required = @findRequired()
		banned = @findBanned()
		allowed = not required and not banned

		<tr>
			<td>{display_names[@props.value]}</td>
			<td><input name={@props.value} type="radio" checked={required} onChange={@require}/></td>
			<td><input name={@props.value} type="radio" checked={allowed} onChange={@allow}/></td>
			<td><input name={@props.value} type="radio" checked={banned} onChange={@ban}/></td>
		</tr>


Requirements = React.createClass
	displayName: "Requirements"

	onEditAssignment: (event) ->
		@props.assignment_text.set event.currentTarget.value

	render: ->
		structures = for structure_type in structure_types
			<RequiredOrBanned value={structure_type} required={@props.required} banned={@props.banned} key={structure_type}/>
		<div>
			<h3>Problem Description</h3>
			<textarea onChange={@onEditAssignment} value={@props.assignment_text.val()} rows={5} className="form-control"></textarea>

			<h3>Feature Usage</h3>
			<div style={height: 300, overflow: 'auto'}>
			<table className="table">
				<thead>
					<th></th>
					<th>Required</th>
					<th>Allowed</th>
					<th>Banned</th>
				</thead>
				<tbody>
					{structures}
				</tbody>
			</table>
			</div>

			<h3>Code Structure</h3>
			<CodeEditor code={@props.code_structure} height={400} mode="ace/mode/json"/>

		</div>


Application = React.createClass
	displayName: "Application"

	render: ->
		feedback = if @props.feedback
			<Feedback feedback={@props.feedback} requirements={@props.cortex.requirements} assignment_text={@props.cortex.assignment_text}/>

		<div className="row">
			<div className="col-sm-4">
				<h2>Code</h2>
				<CodeEditor code={@props.cortex.code} height={700}/>
			</div>
			<div className="col-sm-4">
				<h2>Feedback</h2>
				{feedback}
			</div>
			<div className="col-sm-4">
				<h2>Exercise Settings</h2>
				<Requirements {...@props.cortex.requirements} onChange={@onRequirementChange} assignment_text={@props.cortex.assignment_text}/>				
			</div>
		</div>


default_code = """
for(var x=0; x<5; x++){
	if(x % 2 === 0){
		console.log(x);
	}
}
"""

default_code_structure = """
[
	{
		"type": "ForStatement",
		"body":[
			{
				"type":"IfStatement"
			}
		]
	}
]
"""

default_assignment = """
Write a For Loop with an If statement inside of it.  Do not use a While Loop.
"""

# state management
cortex = new Cortex
	requirements:
		required:['ForStatement','VariableDeclaration','IfStatement']
		banned:['WhileStatement']
		code_structure: default_code_structure
	code: default_code
	assignment_text: default_assignment

application = React.render <Application cortex={cortex}/>, document.getElementById 'application'
cortex.on 'update', (newCortex) ->
	# run tests every time something changes
	try
		feedback = check_code newCortex.code.val(), newCortex.requirements.val()
	catch error
		feedback =
			error: error

	application.setProps
		cortex: newCortex
		feedback: feedback

# initial feedback
feedback = check_code cortex.code.val(), cortex.requirements.val()
application.setProps feedback: feedback