module.exports = (hooks={}) ->

  notAttr = ['children','data']

  emptyTags = ['br','hr','meta','link','base','link','meta','hr','br','img','embed','param','area','col','input']

  $ = (tag, attrs, children, rest...) ->
    hook = hooks[tag]
    return hook.apply $, [attrs, children, rest...] if hook
    return new Node tag, attrs, children

  $.registerHook = (tag, cb) ->
    hooks[tag] = cb

  $.render = render = (nodes) ->
    return _render nodes if !(nodes instanceof Array)
    result = ""
    for node in nodes
      result += _render node
    result

  _render = (node) ->
    return node if typeof node is 'string'
    return render node if node instanceof Array
    {tag,attrs,children} = node
    return "" if !tag
    return """<#{tag}#{_renderAttr(attrs)}/>""" if emptyTags.indexOf(tag) >= 0
    return """<#{tag}#{_renderAttr(attrs)}>#{_renderChildren(children)}</#{tag}>"""

  $.append = (parent,child) ->
    parent.children.push child

  $.prepend = (parent,child) ->
    parent.children.splice 0, 0, child

  $.mergeAttrs = (attrs1,attrs2) ->
    attrs = {}
    for key, val of attrs1
      attrs[key] = val
    for key, val of attrs2
      current = attrs[key]
      if current
        if (current instanceof Array) and (val instanceof Array)
          attrs[key] = current.concat val
        else if (typeof current is 'string') and (typeof val is 'string')
          attrs[key] += current + " " + val
      else
        attrs[key] = val
    return attrs

  $.mergeChildren = (children1=[],children2=[]) ->
    if !(children1 instanceof Array)
      children1 = [children1]
    if !(children2 instanceof Array)
      children2 = [children2]
    return children1.concat children2

  class Node

    constructor: (tag='div',attrs={},children=[])->
      @tag = tag
      @attrs = attrs
      @attrs.class or @attrs.class = []

      if attrs.children
        children = attrs.children
        delete attrs.children

      else if children? and !(children instanceof Array)
        children = [children]

      @children = children

      @

  # Internal
  # ---------------------------

  _renderChildren = (children) ->
    return '' if children?.length <= 0
    html = ''
    for child in children
      if typeof child is 'string'
        html += child
      else
        html += render child
    return html

  _renderAttr = (o) ->
    attrs = ''
    for key, val of o
      continue unless notAttr.indexOf(key) is -1
      val = String(val) if typeof val is 'number'
      if val?.length > 0
        attrs += " " + key + '="'
        if val instanceof Array
          attrs += val.join(" ")
        else
          attrs += val
        attrs += '"'
    return attrs

  # ---------------------------

  return $