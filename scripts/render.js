// Generated by CoffeeScript 1.9.2
(function() {
  var Application, CodeEditor, Feedback, MustHave, MustOrMustnt, Requirements, application, cortex, default_assignment, default_code, default_code_structure, display_names, feedback, key, structure_types,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  CodeEditor = React.createClass({
    componentDidMount: function() {
      var editor, session;
      editor = ace.edit(this.refs.text.getDOMNode());
      editor.$blockScrolling = Infinity;
      session = editor.getSession();
      session.setValue(this.props.code.val());
      session.setMode(this.props.mode || "ace/mode/javascript");
      this.setState({
        session: session
      });
      return session.on('change', (function(_this) {
        return function() {
          return _this.props.code.set(session.getValue());
        };
      })(this));
    },
    render: function() {
      return React.createElement("div", {
        "ref": "text",
        "style": {
          height: this.props.height
        }
      });
    }
  });

  MustHave = React.createClass({
    render: function() {
      var name;
      name = display_names[this.props.value] || this.props.value;
      if (this.props.ok) {
        return React.createElement("li", {
          "className": "good"
        }, React.createElement("span", {
          "className": "glyphicon glyphicon-ok",
          "aria-hidden": "true"
        }), " ", name);
      } else if (this.props.ok === false) {
        return React.createElement("li", {
          "className": "bad"
        }, React.createElement("span", {
          "className": "glyphicon glyphicon-remove",
          "aria-hidden": "true"
        }), " ", name);
      } else {
        return React.createElement("li", {
          "className": "unknown"
        }, React.createElement("span", {
          "className": "glyphicon glyphicon-question-sign",
          "aria-hidden": "true"
        }), " ", name);
      }
    }
  });

  Feedback = React.createClass({
    render: function() {
      var banned, banned_has, banned_nodes, banned_structures, error, ok, required, required_missing, required_nodes, required_structures, structure_match, structure_type;
      if (this.props.feedback.error) {
        error = React.createElement("div", {
          "className": "bad"
        }, React.createElement("span", {
          "className": "glyphicon glyphicon-remove",
          "aria-hidden": "true"
        }), " ", this.props.feedback.error);
        required_structures = this.props.requirements.must_have.val();
        required = required_structures.length ? (required_nodes = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = required_structures.length; i < len; i++) {
            structure_type = required_structures[i];
            results.push(React.createElement(MustHave, {
              "value": structure_type,
              "ok": null,
              "key": structure_type
            }));
          }
          return results;
        })(), React.createElement("div", null, "\t\t\t\t\tYour solution must have:", React.createElement("ul", {
          "className": "list-unstyled"
        }, required_nodes))) : void 0;
        banned_structures = this.props.requirements.mustnt_have.val();
        banned = banned_structures.length ? (banned_nodes = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = banned_structures.length; i < len; i++) {
            structure_type = banned_structures[i];
            results.push(React.createElement(MustHave, {
              "value": structure_type,
              "ok": null,
              "key": structure_type
            }));
          }
          return results;
        })(), React.createElement("div", null, "\t\t\t\t\tYour solution must not have:", React.createElement("ul", {
          "className": "list-unstyled"
        }, banned_nodes))) : void 0;
        return React.createElement("div", null, React.createElement("p", null, this.props.assignment_text.val()), required, banned, error);
      } else {
        required_structures = this.props.requirements.must_have.val();
        required = required_structures.length ? (required_missing = this.props.feedback.must_hasnt, required_nodes = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = required_structures.length; i < len; i++) {
            structure_type = required_structures[i];
            ok = indexOf.call(required_missing, structure_type) < 0;
            results.push(React.createElement(MustHave, {
              "value": structure_type,
              "ok": ok,
              "key": structure_type
            }));
          }
          return results;
        })(), React.createElement("div", null, "\t\t\t\t\tYour solution must have:", React.createElement("ul", {
          "className": "list-unstyled"
        }, required_nodes))) : void 0;
        banned_structures = this.props.requirements.mustnt_have.val();
        banned = banned_structures.length ? (banned_has = this.props.feedback.mustnt_has, banned_nodes = (function() {
          var i, len, results;
          results = [];
          for (i = 0, len = banned_structures.length; i < len; i++) {
            structure_type = banned_structures[i];
            ok = indexOf.call(banned_has, structure_type) < 0;
            results.push(React.createElement(MustHave, {
              "value": structure_type,
              "ok": ok,
              "key": structure_type
            }));
          }
          return results;
        })(), React.createElement("div", null, "\t\t\t\t\tYour solution must not have:", React.createElement("ul", {
          "className": "list-unstyled"
        }, banned_nodes))) : void 0;
        structure_match = this.props.feedback.structure_match ? React.createElement(MustHave, {
          "value": "Structure matches",
          "ok": true
        }) : React.createElement(MustHave, {
          "value": "Structure doesn't match",
          "ok": false
        });
        return React.createElement("div", null, React.createElement("p", null, this.props.assignment_text.val()), required, banned, React.createElement("ul", {
          "className": "list-unstyled"
        }, structure_match));
      }
    }
  });

  display_names = {
    IfStatement: "If Statement",
    WhileStatement: "While Loop",
    ForStatement: "For Loop",
    VariableDeclaration: "Variable Declaration"
  };

  structure_types = (function() {
    var results;
    results = [];
    for (key in display_names) {
      results.push(key);
    }
    return results;
  })();

  MustOrMustnt = React.createClass({
    require: function() {
      var ref;
      if (!this.findRequired()) {
        this.props.required.push(this.props.value);
      }
      return (ref = this.findBanned()) != null ? ref.remove() : void 0;
    },
    ban: function() {
      var ref;
      if (!this.findBanned()) {
        this.props.banned.push(this.props.value);
      }
      return (ref = this.findRequired()) != null ? ref.remove() : void 0;
    },
    allow: function() {
      var ref, ref1;
      if ((ref = this.findRequired()) != null) {
        ref.remove();
      }
      return (ref1 = this.findBanned()) != null ? ref1.remove() : void 0;
    },
    findRequired: function() {
      return this.props.required.find((function(_this) {
        return function(item) {
          return item.val() === _this.props.value;
        };
      })(this));
    },
    findBanned: function() {
      return this.props.banned.find((function(_this) {
        return function(item) {
          return item.val() === _this.props.value;
        };
      })(this));
    },
    render: function() {
      var allowed, banned, required;
      required = this.findRequired();
      banned = this.findBanned();
      allowed = !required && !banned;
      return React.createElement("tr", null, React.createElement("td", null, display_names[this.props.value]), React.createElement("td", null, React.createElement("input", {
        "name": this.props.value,
        "type": "radio",
        "checked": required,
        "onChange": this.require
      })), React.createElement("td", null, React.createElement("input", {
        "name": this.props.value,
        "type": "radio",
        "checked": allowed,
        "onChange": this.allow
      })), React.createElement("td", null, React.createElement("input", {
        "name": this.props.value,
        "type": "radio",
        "checked": banned,
        "onChange": this.ban
      })));
    }
  });

  Requirements = React.createClass({
    onEditAssignment: function(event) {
      return this.props.assignment_text.set(event.currentTarget.value);
    },
    render: function() {
      var structure_type, structures;
      structures = (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = structure_types.length; i < len; i++) {
          structure_type = structure_types[i];
          results.push(React.createElement(MustOrMustnt, {
            "value": structure_type,
            "required": this.props.must_have,
            "banned": this.props.mustnt_have,
            "key": structure_type
          }));
        }
        return results;
      }).call(this);
      return React.createElement("div", null, React.createElement("h3", null, "Assignment"), React.createElement("textarea", {
        "onChange": this.onEditAssignment,
        "value": this.props.assignment_text.val(),
        "rows": 5.,
        "className": "form-control"
      }), React.createElement("table", {
        "className": "table"
      }, React.createElement("thead", null, React.createElement("th", null), React.createElement("th", null, "Required"), React.createElement("th", null, "Allowed"), React.createElement("th", null, "Banned")), React.createElement("tbody", null, structures)), React.createElement("h3", null, "Code Structure"), React.createElement(CodeEditor, {
        "code": this.props.code_structure,
        "height": 400.,
        "mode": "ace/mode/json"
      }));
    }
  });

  Application = React.createClass({
    render: function() {
      var feedback;
      feedback = this.props.feedback ? React.createElement(Feedback, {
        "feedback": this.props.feedback,
        "requirements": this.props.cortex.requirements,
        "assignment_text": this.props.cortex.assignment_text
      }) : void 0;
      return React.createElement("div", {
        "className": "row"
      }, React.createElement("div", {
        "className": "col-sm-4"
      }, React.createElement("h2", null, "Code"), React.createElement(CodeEditor, {
        "code": this.props.cortex.code,
        "height": 700.
      })), React.createElement("div", {
        "className": "col-sm-4"
      }, React.createElement("h2", null, "Feedback"), feedback), React.createElement("div", {
        "className": "col-sm-4"
      }, React.createElement("h2", null, "Exercise Settings"), React.createElement(Requirements, React.__spread({}, this.props.cortex.requirements, {
        "onChange": this.onRequirementChange,
        "assignment_text": this.props.cortex.assignment_text
      }))));
    }
  });

  default_code = "var y = 5;\nif(y){\n	for(x=0; x<5; x++){\n		console.log('yay')\n	}\n}";

  default_code_structure = "[\n	{\n		\"type\": \"IfStatement\",\n		\"consequent\":[\n			{\n				\"type\":\"ForStatement\"\n			}\n		]\n	}\n]";

  default_assignment = "Write an If statement with a For Loop inside of it.  Do not use a While Loop.";

  cortex = new Cortex({
    requirements: {
      must_have: ['ForStatement'],
      mustnt_have: ['WhileStatement'],
      code_structure: default_code_structure
    },
    code: default_code,
    assignment_text: default_assignment
  });

  application = React.render(React.createElement(Application, {
    "cortex": cortex
  }), document.getElementById('application'));

  cortex.on('update', function(newCortex) {
    var error, feedback;
    try {
      feedback = check_code(newCortex.code.val(), newCortex.requirements.val());
    } catch (_error) {
      error = _error;
      feedback = {
        error: error
      };
    }
    return application.setProps({
      cortex: newCortex,
      feedback: feedback
    });
  });

  feedback = check_code(cortex.code.val(), cortex.requirements.val());

  application.setProps({
    feedback: feedback
  });

}).call(this);
