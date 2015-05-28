var clone,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

clone = require('clone');

module.exports = function($) {
  var isNode, _addClass, _hasClass, _removeClass;
  isNode = $.isNode = function(node) {
    return (node != null) && (typeof node === 'object') && !(node instanceof Array);
  };
  $.append = function(parent, child) {
    if (!isNode(parent)) {
      return parent;
    }
    if (parent.children == null) {
      parent.children = [];
    }
    return parent.children.push(child);
  };
  $.prepend = function(parent, child) {
    if (!isNode(parent)) {
      return parent;
    }
    if (parent.children == null) {
      parent.children = [];
    }
    return parent.children.splice(0, 0, child);
  };
  $.addClass = function(node, names) {
    var name, _i, _len;
    if (node.attributes == null) {
      node.attributes = {};
    }
    if (node.attributes["class"] == null) {
      node.attributes["class"] = [];
    }
    if (!(names instanceof Array)) {
      return _addClass(node, names);
    }
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      name = names[_i];
      _addClass(node, name);
    }
    return node;
  };
  _addClass = function(node, name) {
    var classes;
    if (!isNode(node)) {
      return node;
    }
    classes = node.attributes["class"];
    if (classes.indexOf(name) === -1) {
      classes.push(name);
    }
    return classes;
  };
  $.removeClass = function(node, names) {
    var name, _i, _len;
    if (node.attributes == null) {
      return node;
    }
    if (node.attributes["class"] == null) {
      return node;
    }
    if (!(names instanceof Array)) {
      return _addClass(node, names);
    }
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      name = names[_i];
      _removeClass(node, name);
    }
    return node;
  };
  _removeClass = function(node, name) {
    var classes, i;
    if (!isNode(node)) {
      return node;
    }
    classes = node.attributes["class"];
    i = classes.indexOf(name);
    if (i !== -1) {
      classes.splice(i, 1);
    }
    return classes;
  };
  $.hasClass = function(node, names) {
    var boolean, name, _i, _len;
    if (node.attributes == null) {
      return false;
    }
    if (node.attributes["class"] == null) {
      return false;
    }
    if (!(names instanceof Array)) {
      return _hasClass(node, names);
    }
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      name = names[_i];
      boolean = _hasClass(node, name);
      if (!boolean) {
        return boolean;
      }
    }
    return true;
  };
  _hasClass = function(node, name) {
    return node.attributes["class"].indexOf(name) !== -1;
  };
  $.setAttribute = function(node, key, val) {
    if (!isNode(node)) {
      return node;
    }
    if (node.attributes == null) {
      node.attributes = {};
    }
    node.attributes[key] = val;
    return node;
  };
  $.getAttribute = function(node, key) {
    var _ref;
    return node != null ? (_ref = node.attributes) != null ? _ref[key] : void 0 : void 0;
  };
  $.mergeattributes = function(attributes1, attributes2, exclusions, concatString) {
    var attributes, innerKey, innerVal, key, v1, v2, val;
    if (attributes1 == null) {
      attributes1 = {};
    }
    if (attributes2 == null) {
      attributes2 = {};
    }
    if (exclusions == null) {
      exclusions = [];
    }
    if (concatString == null) {
      concatString = false;
    }
    attributes = {};
    for (key in attributes1) {
      val = attributes1[key];
      if (__indexOf.call(exclusions, key) < 0) {
        attributes[key] = val;
      }
    }
    for (key in attributes2) {
      v2 = attributes2[key];
      v1 = attributes[key];
      if (v1) {
        if ((v1 instanceof Array) && (v2 instanceof Array)) {
          attributes[key] = v1.concat(v2);
        } else if ((typeof v1 === 'string') && (typeof v2 === 'string')) {
          if (v1 !== v2 && concatString) {
            attributes[key] += " " + v2;
          }
        } else if ((typeof v1 === 'object') && (typeof v2 === 'object')) {
          v2 = clone(v2, true);
          for (innerKey in v1) {
            innerVal = v1[innerKey];
            v2[innerKey] = innerVal;
          }
          attributes[key] = v2;
        }
      } else {
        if (__indexOf.call(exclusions, key) < 0) {
          attributes[key] = v2;
        }
      }
    }
    return attributes;
  };
  $.mergeChildren = function(children1, children2) {
    if (children1 == null) {
      children1 = [];
    }
    if (children2 == null) {
      children2 = [];
    }
    if (!(children1 instanceof Array)) {
      children1 = [children1];
    }
    if (!(children2 instanceof Array)) {
      children2 = [children2];
    }
    return children1.concat(children2);
  };
  return $;
};
