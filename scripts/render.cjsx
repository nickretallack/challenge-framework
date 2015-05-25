CodeEditor = React.createClass
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
	render: ->
		name = display_names[@props.value]
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
	render: ->
		if @props.feedback.error
			error = <div className="bad"><span className="glyphicon glyphicon-remove" aria-hidden="true"></span> {@props.feedback.error}</div>

			required_structures = @props.requirements.must_have.val()
			required = if required_structures.length
				required_nodes = for structure_type in required_structures
					<MustHave value={structure_type} ok={null} key={structure_type}/>

				<div>
					Your solution must have:
					<ul className="list-unstyled">{required_nodes}</ul>
				</div>

			banned_structures = @props.requirements.mustnt_have.val()
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
			required_structures = @props.requirements.must_have.val()
			required = if required_structures.length
				required_missing = @props.feedback.must_hasnt
				required_nodes = for structure_type in required_structures
					ok = structure_type not in required_missing
					<MustHave value={structure_type} ok={ok} key={structure_type}/>

				<div>
					Your solution must have:
					<ul className="list-unstyled">{required_nodes}</ul>
				</div>

			banned_structures = @props.requirements.mustnt_have.val()
			banned = if banned_structures.length
				banned_has = @props.feedback.mustnt_has
				banned_nodes = for structure_type in banned_structures
					ok = structure_type not in banned_has
					<MustHave value={structure_type} ok={ok} key={structure_type}/>

				<div>
					Your solution must not have:
					<ul className="list-unstyled">{banned_nodes}</ul>
				</div>

			<div>
				<p>{@props.assignment_text.val()}</p>
				{required}
				{banned}
			</div>


display_names =
	IfStatement: "If Statement"
	WhileStatement: "While Loop"
	ForStatement: "For Loop"
	VariableDeclaration: "Variable Declaration"

structure_types = (key for key of display_names)

MustOrMustnt = React.createClass
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
	onEditAssignment: (event) ->
		@props.assignment_text.set event.currentTarget.value

	render: ->
		structures = for structure_type in structure_types
			<MustOrMustnt value={structure_type} required={@props.must_have} banned={@props.mustnt_have} key={structure_type}/>
		<div>
			<h3>Assignment</h3>
			<textarea onChange={@onEditAssignment} value={@props.assignment_text.val()} rows={5} className="form-control"></textarea>

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

			<h3>Code Structure</h3>
			<CodeEditor code={@props.code_structure} height={400} mode="ace/mode/json"/>

		</div>

Application = React.createClass
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
var y = 5;
if(y){
	for(x=0; x<5; x++){
		console.log('yay')
	}
}
"""

default_code_structure = """
[
	{
		"type": "IfStatement",
		"consequent":{
			"type":"ForStatement"
		}
	}
]
"""

default_assignment = """
Write an If statement with a For Loop inside of it.  Do not use a While Loop.
"""

# state management
cortex = new Cortex
	requirements:
		must_have:['ForStatement']
		mustnt_have:['WhileStatement']
		code_structure: default_code_structure
	code: default_code
	assignment_text: default_assignment

application = React.render <Application cortex={cortex}/>, document.getElementById 'application'
cortex.on 'update', (newCortex) ->
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