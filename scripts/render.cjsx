CodeEditor = React.createClass
	componentDidMount: ->
		editor = ace.edit @refs.text.getDOMNode()
		editor.$blockScrolling = Infinity
		session = editor.getSession()
		session.setValue @props.code.val()
		session.setMode "ace/mode/javascript"
		@setState session: session
		session.on 'change', =>
			@props.code.set session.getValue()

	render: ->
		<div>
			<h2>Code</h2>
			<div ref="text" style={height:@props.height}></div>
		</div>

MustHave = React.createClass
	render: ->
		if @props.ok
			<li className="good">
				<span className="glyphicon glyphicon-ok" aria-hidden="true"></span> {@props.value}
			</li>
		else
			<li className="bad">
				<span className="glyphicon glyphicon-remove" aria-hidden="true"></span> {@props.value}
			</li>

Feedback = React.createClass
	render: ->
		content = if @props.feedback.error
			<div className="bad"><span className="glyphicon glyphicon-remove" aria-hidden="true"></span> {@props.feedback.error}</div>
		else
			must_hasnt = @props.feedback.must_hasnt
			must_have = for structure_type in @props.requirements.must_have.val()
				ok = structure_type not in must_hasnt #@props.feedback.must_hasnt.find (item) => item.val() == structure_type
				<MustHave value={structure_type} ok={ok}/>

			<div>
				Your solution must have:
				<ul className="list-unstyled">{must_have}</ul>
			</div>

		<div>
			<h2>Feedback</h2>
			{content}
		</div>

structure_types = ['IfStatement','WhileStatement','ForStatement','VariableDeclaration']

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
			<td>{@props.value}</td>
			<td class="radio"><label><input name={@props.value} type="radio" checked={required} onChange={@require}/></label></td>
			<td class="radio"><label><input name={@props.value} type="radio" checked={allowed} onChange={@allow}/></label></td>
			<td class="radio"><label><input name={@props.value} type="radio" checked={banned} onChange={@ban}/></label></td>
		</tr>

Requirements = React.createClass
	render: ->
		structures = for structure_type in structure_types
			<MustOrMustnt value={structure_type} required={@props.must_have} banned={@props.mustnt_have}/>
		<div>
			<h2>Exercise Settings</h2>

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
			<CodeEditor code={@props.code_structure} height={400}/>

		</div>

Application = React.createClass
	render: ->

		feedback = if @props.feedback
			<Feedback feedback={@props.feedback} requirements={@props.cortex.requirements}/>

		<div className="row">
			<div className="col-sm-4">
				<CodeEditor code={@props.cortex.code} height={700}/>
			</div>
			<div className="col-sm-4">
				{feedback}
			</div>
			<div className="col-sm-4">
				<Requirements {...@props.cortex.requirements} onChange={@onRequirementChange}/>				
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
for(;;) {
	if (){

	}
}

"""

# state management
cortex = new Cortex
	requirements:
		must_have:['IfStatement']
		mustnt_have:['WhileStatement']
		code_structure: default_code_structure
	code: default_code

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