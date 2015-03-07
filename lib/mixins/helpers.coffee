module.exports = ($) ->

  $.append = (parent,child) ->
    parent.children = [] unless parent.children?
    parent.children.push child

  $.prepend = (parent,child) ->
    parent.children = [] unless parent.children?
    parent.children.splice 0, 0, child

  $.addClass = (node,names) ->
    node.attributes = {} unless node.attributes?
    node.attributes.class = [] unless node.attributes.class?
    return _addClass(node,names) unless names instanceof Array
    for name in names
      _addClass(node,name)
    node

  _addClass = (node,name) ->
    classes = node.attributes.class
    classes.push(name) if classes.indexOf(name) is -1
    classes

  $.removeClass = (node,names) ->
    return node unless node.attributes?
    return node unless node.attributes.class?
    return _addClass(node,names) unless names instanceof Array
    for name in names
      _removeClass(node,name)
    node

  _removeClass = (node, name) ->
    classes = node.attributes.class
    i = classes.indexOf(name)
    classes.splice(i,1) if i isnt -1
    classes

  $.hasClass = (node,names) ->
    return false unless node.attributes?
    return false unless node.attributes.class?
    return _hasClass(node,names) unless names instanceof Array
    for name in names
      boolean = _hasClass(node,name)
      return boolean unless boolean
    true

  _hasClass = (node,name) ->
    return node.attributes.class.indexOf(name) isnt -1

  $.mergeattributes = (attributes1={},attributes2={}) ->
    # merge shared key values where value is same type, preferring attributes1, otherwise fallback to attributes2
    attributes = {}
    for key, val of attributes1
      attributes[key] = val
    for key, v2 of attributes2
      v1 = attributes[key]
      if v1
        if (v1 instanceof Array) and (v2 instanceof Array)
          attributes[key] = v1.concat v2
        else if (typeof v1 is 'string') and (typeof v2 is 'string')
          attributes[key] += v1 + " " + v2
        else if (typeof v1 is 'object') and (typeof v2 is 'object')
          # TODO: not clone
          # clone to not disrupt $h!t up the closures
          v2 = JSON.parse JSON.stringify v2
          # prefer styles from attributes1
          for innerKey, innerVal of v1
            v2[innerKey] = innerVal
          attributes[key] = v2
      else
        attributes[key] = v2
    return attributes

  $.mergeChildren = (children1=[],children2=[]) ->
    if !(children1 instanceof Array)
      children1 = [children1]
    if !(children2 instanceof Array)
      children2 = [children2]
    return children1.concat children2

  $