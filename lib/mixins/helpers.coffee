clone = require 'clone'

module.exports = do ->

  NOT_ATTR = [
    'children'
    'data'
  ]

  EMPTY_TAGS = [
    'br'
    'hr'
    'meta'
    'link'
    'base'
    'img'
    'embed'
    'param'
    'area'
    'col'
    'input'
  ]

  isNode = (node) ->
    return node? and (typeof node is 'object') and !(node instanceof Array)

  append = (parent,child) ->
    return parent unless isNode parent
    parent.children = [] unless parent.children?
    parent.children.push child

  prepend = (parent,child) ->
    return parent unless isNode parent
    parent.children = [] unless parent.children?
    parent.children.splice 0, 0, child

  addClass = (node,names) ->
    node.attributes = {} unless node.attributes?
    node.attributes.class = [] unless node.attributes.class?
    return _addClass(node,names) unless names instanceof Array
    for name in names
      _addClass(node,name)
    node

  _addClass = (node,name) ->
    return node unless isNode node
    classes = node.attributes.class
    classes.push(name) if classes.indexOf(name) is -1
    classes

  removeClass = (node,names) ->
    return node unless node.attributes?
    return node unless node.attributes.class?
    return _addClass(node,names) unless names instanceof Array
    for name in names
      _removeClass(node,name)
    node

  _removeClass = (node, name) ->
    return node unless isNode node
    classes = node.attributes.class
    i = classes.indexOf(name)
    classes.splice(i,1) if i isnt -1
    classes

  hasClass = (node,names) ->
    return false unless node.attributes?
    return false unless node.attributes.class?
    return _hasClass(node,names) unless names instanceof Array
    for name in names
      boolean = _hasClass(node,name)
      return boolean unless boolean
    true

  _hasClass = (node,name) ->
    return node.attributes.class.indexOf(name) isnt -1

  getFirstDescendant = (node, childTagNames) ->
    if node? and node.children instanceof Array
      for tagName in childTagNames #order are prioritize.
        for child in node.children
          return child if child? and child.tag is tagName

      for child in node.children
        foundChild = getFirstDescendant(child, childTagNames)
        return foundChild if foundChild

    return null

  getChildren = (node, childTagNames, classNames, isChild=false) ->
    return null unless childTagNames or classNames
    foundChild = []

    if isChild
      matches = false

      if childTagNames
        matches = true if node?.tag in childTagNames
      else
        matches = true

      if matches and classNames
        if node.attributes?.class?
          matches = true
          for c in classNames
            if node.attributes.class.indexOf(c) is -1
              matches = false
              break
        else
          matches = false

      foundChild.push node if matches

    if node?.children?
      for child in node.children
        childResult = getChildren(child, childTagNames, classNames, true)
        Array.prototype.push.apply(foundChild,childResult) if childResult?.length > 0

    return foundChild

  setAttribute = (node,key,val) ->
    return node unless isNode(node)
    node.attributes = {} unless node.attributes?
    node.attributes[key] = val
    return node

  getAttribute = (node,key) ->
    node?.attributes?[key]

  mergeAttributes = (attributes1={},attributes2={},exclusions=[],concatString=false) ->
    # merge shared key values where value is same type, preferring attributes1, otherwise fallback to attributes2
    attributes = {}
    for key, val of attributes1
      attributes[key] = val unless key in exclusions
    for key, v2 of attributes2
      v1 = attributes[key]
      if v1
        if (v1 instanceof Array) and (v2 instanceof Array)
          attributes[key] = v1.concat v2
        else if (typeof v1 is 'string') and (typeof v2 is 'string')
          if v1 isnt v2 and concatString
            attributes[key] += " " + v2
        else if (typeof v1 is 'object') and (typeof v2 is 'object')
          # TODO: not clone
          # clone to not disrupt $h!t up the closures
          v2 = clone v2, true
          # prefer styles from attributes1
          for innerKey, innerVal of v1
            v2[innerKey] = innerVal
          attributes[key] = v2
      else
        attributes[key] = v2 unless key in exclusions
    return attributes

  mergeChildren = (children1=[],children2=[]) ->
    if !(children1 instanceof Array)
      children1 = [children1]
    if !(children2 instanceof Array)
      children2 = [children2]
    return children1.concat children2

  return {
    EMPTY_TAGS
    NOT_ATTR

    addClass
    append
    getAttribute
    getChildren
    getFirstDescendant
    hasClass
    isNode
    mergeAttributes
    mergeChildren
    prepend
    removeClass
    setAttribute
  }
