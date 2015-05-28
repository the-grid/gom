module.exports = function($) {
  var emptyTags, notAttr, render, _render, _renderAttr, _renderChildren, _renderStyles;
  notAttr = $.notAttr, emptyTags = $.emptyTags;
  $.render = render = function(nodes) {
    var node, result, _i, _len;
    if (!(nodes instanceof Array)) {
      return _render(nodes);
    }
    result = "";
    for (_i = 0, _len = nodes.length; _i < _len; _i++) {
      node = nodes[_i];
      result += _render(node);
    }
    return result;
  };
  _render = function(node) {
    var attributes, children, tag;
    if (!node) {
      return '';
    }
    if (typeof node === 'string') {
      return node;
    }
    if (node instanceof Array) {
      return render(node);
    }
    if (typeof node === 'function') {
      return render(node());
    }
    tag = node.tag, attributes = node.attributes, children = node.children;
    tag || (tag = 'div');
    attributes || (attributes = {});
    children || (children = []);
    if (!tag) {
      return "";
    }
    if (emptyTags.indexOf(tag) >= 0) {
      return "<" + tag + (_renderAttr(attributes)) + "/>";
    }
    return "<" + tag + (_renderAttr(attributes)) + ">" + (_renderChildren(children)) + "</" + tag + ">";
  };
  _renderChildren = function(children) {
    var child, html, _i, _len;
    if ((children != null ? children.length : void 0) <= 0) {
      return '';
    }
    html = '';
    for (_i = 0, _len = children.length; _i < _len; _i++) {
      child = children[_i];
      if (typeof child === 'string') {
        html += child;
      } else {
        html += render(child);
      }
    }
    return html;
  };
  _renderStyles = function(o) {
    var key, style, val;
    if (typeof o !== "object") {
      return o;
    }
    style = "";
    for (key in o) {
      val = o[key];
      if (typeof val === 'number') {
        val = String(val);
      }
      style += key + ":" + val + "; ";
    }
    style = style.slice(0, style.length - 2);
    return style.trim();
  };
  _renderAttr = function(o) {
    var attributes, key, val;
    attributes = '';
    if (!o) {
      return attributes;
    }
    for (key in o) {
      val = o[key];
      if (notAttr.indexOf(key) !== -1) {
        continue;
      }
      if (key === 'style') {
        val = _renderStyles(val);
      } else {
        if (typeof val === 'number') {
          val = String(val);
        }
      }
      if ((val != null ? val.length : void 0) > 0) {
        if (!((key === 'class' || key === 'style') || typeof val === 'string')) {
          continue;
        }
        attributes += " " + key + '="';
        if (key === 'class' && val instanceof Array) {
          attributes += val.join(" ");
        } else {
          attributes += val;
        }
        attributes += '"';
      }
    }
    return attributes;
  };
  return $;
};
