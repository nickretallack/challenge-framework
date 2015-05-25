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
			<div ref="text" style={height:700}></div>
		</div>

# CodeEditor = React.createClass
# 	onChange: (event) ->
# 		@props.code.set @refs.text.getDOMNode().value

# 	render: ->
# 		<div>
# 			<h2>Code</h2>
# 			<textarea onChange={@onChange} ref="text" value={@props.code.val()} className="form-control" rows="40"></textarea>
# 		</div>

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
		must_hasnt = @props.feedback.must_hasnt
		must_have = for structure_type in @props.requirements.must_have.val()
			ok = structure_type not in must_hasnt #@props.feedback.must_hasnt.find (item) => item.val() == structure_type
			<MustHave value={structure_type} ok={ok}/>

		<div>
			<h2>Feedback</h2>
			Your solution must have:
			<ul className="list-unstyled">{must_have}</ul>

			Some feedback
		</div>

structure_types = ['IfStatement','WhileStatement','ForStatement','VariableDeclaration']

ListCheckbox = React.createClass
	onChange: (event) ->
		checked = event.currentTarget.checked
		was_checked = @isChecked()
		if checked and not was_checked
			@props.list.push @props.value
		if not checked and was_checked
			was_checked.remove()

	isChecked: ->
		@props.list.find (item) => item.val() == @props.value

	render: ->
		checked = @isChecked()
		<div className="checkbox">
			<label>
				<input type="checkbox" checked={checked} onChange={@onChange}/> {@props.value}
			</label>
		</div>

Requirements = React.createClass
	render: ->
		must_have = for structure_type in structure_types
			<ListCheckbox value={structure_type} list={@props.must_have} key={structure_type}/>

		mustnt_have = for structure_type in structure_types
			<ListCheckbox value={structure_type} list={@props.mustnt_have} key={structure_type}/>

		<div>
			<h2>Exercise Settings</h2>
			<h3>Must Have</h3>
			{must_have}

			<h3>Mustnt Have</h3>
			{mustnt_have}
		</div>

Application = React.createClass
	render: ->

		feedback = if @props.feedback
			<Feedback feedback={@props.feedback} requirements={@props.cortex.requirements}/>

		<div className="row">
			<div className="col-sm-5">
				<CodeEditor code={@props.cortex.code}/>
			</div>
			<div className="col-sm-4">
				{feedback}
			</div>
			<div className="col-sm-3">
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

# state management
cortex = new Cortex
	requirements:
		must_have:['IfStatement']
		mustnt_have:['WhileStatement']
	code: default_code

application = React.render <Application cortex={cortex}/>, document.getElementById 'application'
cortex.on 'update', (newCortex) ->
	try
		feedback = check_code newCortex.code.val(), newCortex.requirements.val()
	catch
		feedback = null

	application.setProps
		cortex: newCortex
		feedback: feedback

# initial feedback
feedback = check_code cortex.code.val(), cortex.requirements.val()
application.setProps feedback: feedback