module.exports = (hooks={}) ->

  notAttr = ['children','data']

  emptyTags = ['br','hr','meta','link','base','img','embed','param','area','col','input']

  $ = (tag, attributes, children, rest...) ->
    hook = hooks[tag]
    return hook.apply $, [attributes, children, rest...] if hook
    return new Node tag, attributes, children

  $.registerHook = (tag, cb) ->
    hooks[tag] = cb

  $.render = render = (nodes) ->
    return _render nodes if !(nodes instanceof Array)
    result = ""
    for node in nodes
      result += _render node
    result

  _transformNodes = (nodes, transformations) ->
    newNodes = []
    for node in nodes
      newNode = transform node, transformations
      # removes falsy children
      newNodes.push(newNode) if newNode
    newNodes

  _transformNode = (node, transformations) ->

    # recurse children first
    # otherwise wrapping transformations = infinite loop
    if node.children?
      node.children = transform node.children, transformations

    for t in transformations

      if typeof t is 'function'
        node = t.call $, node

      else if typeof t is 'object'
        for selector, callback of t
          node = callback.call($,node) if node.tag is selector

    node

  transform = (nodes, transformations) ->
    # return if falsy child
    return nodes unless nodes?

    return _transformNodes(nodes, transformations) if nodes instanceof Array

    # if child is function, evaluate it
    return transform(node(), transformations) if typeof node is 'function'

    return _transformNode nodes, transformations

  $.transform = (nodes, transformations) ->
    throw new Error "GOM Transformations must be an Array" unless transformations instanceof Array
    return transform nodes, transformations

  _render = (node) ->
    return '' if !node
    return node if typeof node is 'string'
    return render node if node instanceof Array
    return render node() if typeof node is 'function'

    {tag,attributes,children} = node

    # in case JSON passed
    tag or tag='div'
    attributes or attributes={}
    children or children=[]

    return "" if !tag
    return """<#{tag}#{_renderAttr(attributes)}/>""" if emptyTags.indexOf(tag) >= 0
    return """<#{tag}#{_renderAttr(attributes)}>#{_renderChildren(children)}</#{tag}>"""

  $.append = (parent,child) ->
    parent.children = [] if !parent.children?
    parent.children.push child

  $.prepend = (parent,child) ->
    parent.children = [] if !parent.children?
    parent.children.splice 0, 0, child

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


  class Node

    constructor: (tag,attributes,children)->
      tag or tag='div'
      #attributes or attributes={}
      #children or children=[]

      @tag = tag

      if attributes

        @attributes = attributes
        #@attributes.class or @attributes.class = []

      if attributes?.children
        children = attributes.children
        delete attributes.children

      else if children? and !(children instanceof Array)
        children = [children]

      @children = children if children

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

  _renderStyles = (o) ->
    return o unless typeof o is "object"
    style = ""
    for key, val of o
      val = String(val) if typeof val is 'number'
      style += key + ":" + val + "; "
    # remove last semi-colon and whitespace
    style = style.slice(0,style.length-2)
    return style.trim()

  _renderAttr = (o) ->
    attributes = ''
    return attributes if !o
    for key, val of o
      continue unless notAttr.indexOf(key) is -1
      if key is 'style'
        val = _renderStyles val
      else
        val = String(val) if typeof val is 'number'
      if val?.length > 0
        attributes += " " + key + '="'
        if val instanceof Array
          attributes += val.join(" ")
        else
          attributes += val
        attributes += '"'
    return attributes


  # Tree Walking
  # ---------------------------

  $.querySelectorAll = (tree, selector) ->



  # ---------------------------

  return $