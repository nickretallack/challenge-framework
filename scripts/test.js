// Generated by CoffeeScript 1.9.2
(function() {
  var snippet,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  window.check_code = function(string, arg) {
    var code_structure, i, len, must_has, must_hasnt, must_have, mustnt_has, mustnt_have, node, parsed, ref, structure_has, type, visit_node;
    must_have = arg.must_have, mustnt_have = arg.mustnt_have, code_structure = arg.code_structure;
    must_have || (must_have = []);
    mustnt_have || (mustnt_have = []);
    structure_has = JSON.parse(code_structure);
    parsed = esprima.parse(string);
    console.log(parsed);
    must_has = [];
    mustnt_has = [];
    visit_node = function(node, structure_pointers) {
      var found_structures, i, j, len, len1, pointer, ref, ref1, ref2, ref3, structure, visit_child;
      if (node === null) {
        return;
      }
      if ((ref = node.type, indexOf.call(mustnt_have, ref) >= 0) && (ref1 = node.type, indexOf.call(mustnt_has, ref1) < 0)) {
        mustnt_has.push(node.type);
      }
      if ((ref2 = node.type, indexOf.call(must_have, ref2) >= 0) && (ref3 = node.type, indexOf.call(must_has, ref3) < 0)) {
        must_has.push(node.type);
      }
      found_structures = [];
      for (i = 0, len = structure_pointers.length; i < len; i++) {
        pointer = structure_pointers[i];
        for (j = 0, len1 = pointer.length; j < len1; j++) {
          structure = pointer[j];
          if (node.type === structure.type) {
            structure.has = true;
            found_structures.push(structure);
          }
        }
      }
      visit_child = function(node, key) {
        var child, child_node, child_structure_pointers, child_structures_pointers, k, l, len2, len3;
        child_structure_pointers = [];
        child_structures_pointers = child_structure_pointers.concat(structure_pointers);
        for (k = 0, len2 = found_structures.length; k < len2; k++) {
          structure = found_structures[k];
          if (key in structure) {
            child_structures_pointers = child_structure_pointers.concat(structure[key]);
          }
        }
        child = node[key];
        if ($.isArray(child)) {
          for (l = 0, len3 = child.length; l < len3; l++) {
            child_node = child[l];
            visit_node(child_node, child_structure_pointers);
          }
        } else if (child) {
          visit_node(child, child_structure_pointers);
        }
        return void 0;
      };
      if (node.type === 'IfStatement') {
        visit_child(node, 'consequent');
        visit_child(node, 'alternate');
      }
      if (node.body != null) {
        visit_child(node, 'body');
      }
      return void 0;
    };
    ref = parsed.body;
    for (i = 0, len = ref.length; i < len; i++) {
      node = ref[i];
      visit_node(node, [structure_has]);
    }
    must_hasnt = (function() {
      var j, len1, results;
      results = [];
      for (j = 0, len1 = must_have.length; j < len1; j++) {
        type = must_have[j];
        if (indexOf.call(must_has, type) < 0) {
          results.push(type);
        }
      }
      return results;
    })();
    console.log(structure_has);
    return {
      must_hasnt: must_hasnt,
      mustnt_has: mustnt_has,
      structure_has: structure_has
    };
  };

  snippet = "var y = 5;\nif(y){\n	for(x=0; x<5; x++){\n		console.log('yay')\n	}\n}";

}).call(this);
