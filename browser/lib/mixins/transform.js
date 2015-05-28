var __slice = [].slice;

module.exports = function($) {
  var transform, _transform, _transformNode, _transformNodes;
  $.transform = transform = function() {
    var args, nodes, transforms;
    nodes = arguments[0], transforms = arguments[1], args = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    if (!(transforms instanceof Array)) {
      transforms = [transforms];
    }
    return _transform(nodes, transforms, args);
  };
  _transform = function(nodes, transforms, args) {
    if (nodes == null) {
      return nodes;
    }
    if (nodes instanceof Array) {
      return _transformNodes(nodes, transforms, args);
    }
    if (typeof node === 'function') {
      return _transform(node(), transforms, args);
    }
    return _transformNode(nodes, transforms, args);
  };
  _transformNodes = function(nodes, transforms, args) {
    var newNode, newNodes, node, _i, _len;
    newNodes = [];
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      node = nodes[_i];
      newNode = _transform(node, transforms, args);
      if (newNode) {
        newNodes.push(newNode);
      }
    }
    return newNodes;
  };
  _transformNode = function(node, transforms, args) {
    var callback, selector, t, _i, _len;
    if (node.children != null) {
      node.children = transform(node.children, transforms);
    }
    for (_i = 0, _len = transforms.length; _i < _len; _i++) {
      t = transforms[_i];
      if (typeof t === 'function') {
        node = t.call.apply(t, [$, node].concat(__slice.call(args)));
      } else if (typeof t === 'object') {
        for (selector in t) {
          callback = t[selector];
          if (node.tag === selector) {
            node = callback.call.apply(callback, [$, node].concat(__slice.call(args)));
          }
        }
      }
    }
    return node;
  };
  return $;
};
