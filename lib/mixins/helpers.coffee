module.exports = do ->

  clone = require 'clone'

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

  IS_CHILD = true
  NOT_FOUND = -1

  isNode = (node) ->
    return node and typeof node is 'object' and node not instanceof Array

  append = (parent, child) ->
    if isNode parent
      parent.children ?= []
      parent.children.push child
    return

  prepend = (parent, child) ->
    if isNode parent
      parent.children ?= []
      parent.children.splice 0, 0, child
    return

  # return value inconsistent...
  addClass = (node, names) ->
    node.attributes ?= {}
    node.attributes.class ?= []
    if names not instanceof Array
      return _addClass node, names
    for name in names
      _addClass node, name
    return node

  # node.attributes.class should exist at this point
  # inconsistent return value
  _addClass = (node, name) ->
    unless isNode node
      return node
    classes = node.attributes.class
    if classes.indexOf(name) is NOT_FOUND
      classes.push name
    return classes

  # inconsistent return value
  removeClass = (node, names) ->
    unless node.attributes?.class?
      return node
    if names not instanceof Array # Wtf?
      return _addClass node, names
    for name in names
      _removeClass node, name
    return node

  # node.attributes.class should exist at this point
  # inconsistent return value
  _removeClass = (node, name) ->
    unless isNode node # move out of this function
      return node
    classes = node.attributes.class
    i = classes.indexOf name
    unless i is NOT_FOUND
      classes.splice i, 1
    return classes

  hasClass = (node, names) ->
    unless node.attributes?.class?
      return false
    if names not instanceof Array
      return _hasClass node, names
    for name in names
      unless _hasClass node, name
        return false
    return true

  _hasClass = (node, name) ->
    return node.attributes.class.indexOf(name) isnt NOT_FOUND

  getFirstDescendant = (node, childTagNames) ->
    children = node?.children
    if children instanceof Array
      for tagName in childTagNames #order are prioritize.
        for child in children
          if child?.tag is tagName
            return child

      for child in children
        foundChild = getFirstDescendant child, childTagNames
        if foundChild
          return foundChild

    return null

  getChildren = (node, childTagNames, classNames, isChild = false) ->
    unless childTagNames or classNames
      return null

    foundChildren = []
    _getChildren node, childTagNames, classNames, foundChildren, isChild
    return foundChildren

  _getChildren = (node, childTagNames, classNames, foundChildren, isChild = false) ->
    if node and isChild and _isNodeMatch node, childTagNames, classNames
      foundChildren.push node

    children = node.children
    if children
      for child in children
        _getChildren child, childTagNames, classNames, foundChildren, IS_CHILD

    return

  _isNodeMatch = (node, childTagNames, classNames) ->
    if childTagNames
      if childTagNames.indexOf(node.tag) is NOT_FOUND
        return false

    if classNames
      nodeClass = node.attributes?.class
      unless nodeClass?
        return false
      for c in classNames
        if nodeClass.indexOf(c) is NOT_FOUND
          return false

    return true

  setAttribute = (node, key, val) ->
    if isNode node
      node.attributes ?= {}
      node.attributes[key] = val
    return node

  getAttribute = (node, key) ->
    return node?.attributes?[key]

  mergeAttributes = (attributes1 = {}, attributes2 = {}, exclusions = [], concatString = false) ->
    # merge shared key values where value is same type, preferring attributes1, otherwise fallback to attributes2
    attributes = {}

    for key, val of attributes1
      if exclusions.indexOf(key) is NOT_FOUND
        attributes[key] = val

    for key, v2 of attributes2
      v1 = attributes[key]
      if v1
        if v1 instanceof Array and v2 instanceof Array
          attributes[key] = v1.concat v2
        else if typeof v1 is 'string' and typeof v2 is 'string'
          if v1 isnt v2 and concatString
            attributes[key] += " " + v2
        else if typeof v1 is 'object' and typeof v2 is 'object'
          # TODO: not clone
          # clone to not disrupt $h!t up the closures
          v2 = clone v2, true
          # prefer styles from attributes1
          for innerKey, innerVal of v1
            v2[innerKey] = innerVal
          attributes[key] = v2
      else if exclusions.indexOf(key) is NOT_FOUND
        attributes[key] = v2

    return attributes

  mergeChildren = (children1 = [], children2 = []) ->
    if children1 not instanceof Array
      children1 = [children1]

    if children2 not instanceof Array
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
