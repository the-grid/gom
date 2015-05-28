var __slice = [].slice;

module.exports = function(hooks) {
  var $, Node;
  if (hooks == null) {
    hooks = {};
  }
  $ = function() {
    var attributes, children, hook, rest, tag;
    tag = arguments[0], attributes = arguments[1], children = arguments[2], rest = 4 <= arguments.length ? __slice.call(arguments, 3) : [];
    hook = hooks[tag];
    if (hook) {
      return hook.apply($, [attributes, children].concat(__slice.call(rest)));
    }
    return new Node(tag, attributes, children);
  };
  $.registerHook = function(tag, cb) {
    return hooks[tag] = cb;
  };
  $.notAttr = ['children', 'data'];
  $.emptyTags = ['br', 'hr', 'meta', 'link', 'base', 'img', 'embed', 'param', 'area', 'col', 'input'];
  require('./mixins/helpers')($);
  require('./mixins/render')($);
  require('./mixins/transform')($);
  Node = (function() {
    function Node(tag, attributes, children) {
      tag || (tag = 'div');
      this.tag = tag;
      if (attributes) {
        this.attributes = attributes;
      }
      if (attributes != null ? attributes.children : void 0) {
        children = attributes.children;
        delete attributes.children;
      } else if ((children != null) && !(children instanceof Array)) {
        children = [children];
      }
      if (children) {
        this.children = children;
      }
      this;
    }

    return Node;

  })();
  return $;
};
