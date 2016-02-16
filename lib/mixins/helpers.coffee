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


  ###
  Duck type check whether given node could be a GOM node.
  Only really checks whether node is an object and not an array...
  (We could have it check for `_class` or something similar instead)

  @param {GomNode} [node]
  @returns {boolean}
  ###
  isNode = (node) ->
    return node and typeof node is 'object' and node not instanceof Array

  ###
  Add child to parent if parent is a node. Puts child last.
  TOFIX: issue warning if parent is not a node? because that situation looks a little weird now.

  @param {GomNode} [parent]
  @param {GomNode} child
  ###
  append = (parent, child) ->
    if isNode parent
      parent.children ?= []
      parent.children.push child
    return

  ###
  Add child to parent if parent is a node. Puts child first.
  TOFIX: issue warning if parent is not a node? because that situation looks a little weird now.

  @param {GomNode} [parent]
  @param {GomNode} child
  ###
  prepend = (parent, child) ->
    if isNode parent
      parent.children ?= []
      parent.children.splice 0, 0, child
    return

  ###
  Add name or names to the class of given node

  @param {GomNode} node
  @param {string|string[]} names One or many
  @returns {GomNode} node
  ###
  addClass = (node, names) ->
    node.attributes ?= {}
    node.attributes.class ?= []
    if names not instanceof Array
      _addClass node, names
    else
      for name in names
        _addClass node, name
    return node

  ###
  Add given class name to node if it doesn't already have it.
  Assumes `node.attributes.class` exists

  @param {GomNode} node
  @param {string} name
  ###
  _addClass = (node, name) ->
    if isNode node # TOFIX: this check seems redundant. (currently) all callers already assume it's a node
      classes = node.attributes.class
      if classes.indexOf(name) is NOT_FOUND
        classes.push name
    return

  ###
  Remove name or names from the class of given node

  @param {GomNode} node
  @param {string|string[]} names One or many
  @returns {GomNode} node
  ###
  removeClass = (node, names) ->
    if node.attributes?.class?
      if names not instanceof Array
        _removeClass node, names
      else
        for name in names
          _removeClass node, name
    return node

  ###
  Remove given class name from node if it has it.
  Assumes `node.attributes.class` exists
  Note: only removes the first occurrence!

  @param {GomNode} node
  @param {string} name
  ###
  _removeClass = (node, name) ->
    if isNode node # TOFIX: this check seems redundant. (currently) all callers already assume it's a node
      classes = node.attributes.class
      i = classes.indexOf name
      unless i is NOT_FOUND
        classes.splice i, 1
    return

  ###
  Does the class list of node contain _all_ given names

  @param {GomNode} node
  @param {string|string[]} names
  @returns {boolean}
  ###
  hasClass = (node, names) ->
    unless node.attributes?.class?
      return false
    if names not instanceof Array
      return _hasClass node, names
    for name in names
      unless _hasClass node, name
        return false
    return true

  ###
  Does the class list of node contain given name
  Assumes node has a class

  @param {GomNode} node
  @param {string} names
  @returns {boolean}
  ###
  _hasClass = (node, name) ->
    return node.attributes.class.indexOf(name) isnt NOT_FOUND

  ###
  Find the first descendant with a tag name in the list of tag names.
  Searches in DFS order. If multiple nodes on the same level would
  match, returns the first node of those whose tag name occurs
  earliest in the list of tags. In other worse: the tagNames list is
  also a priority list.

  @param {GomNode} node
  @param {string[]} tagNames Prefer lower indexed names over higher index names of nodes of the same parent
  @param {GomNode|null} Should have a tag name with as low as index in tagNames as possible
  ###
  getFirstDescendant = (node, tagNames) ->
    children = node?.children
    if children instanceof Array
      found = _getBestChildByTag children, tagNames
      if found
        return found

      for child in children
        found = getFirstDescendant child, tagNames
        if found
          return found

    return null

  ###
  For each child in children find the index in tagNames. Return
  the node with lowest (>=0) index, or null if not found.

  @param {GomNode[]} children
  @param {string[]} tagNames
  @returns {GomNode|null}
  ###
  _getBestChildByTag = (children, tagNames) ->
    found = null
    foundIndex = tagNames.length
    for child in children
      tag = child?.tag
      if tag
        index = tagNames.indexOf tag
        if index isnt NOT_FOUND and index < foundIndex
          found = child
          foundIndex = index
    return found

  ###
  Find all children with a certain tag and/or class name.
  Will not search without at least supply a list of class names or tag names.

  @param {GomNode} node The parent
  @param {string[]} [childTagNames]
  @param {string[]} [classNames]
  @param {boolean} [isChild=false]
  @returns {GomNode[]|null}
  ###
  getChildren = (node, childTagNames, classNames, isChild = false) ->
    unless childTagNames or classNames
      return null

    foundChildren = []
    _getChildren node, childTagNames, classNames, foundChildren, isChild
    return foundChildren

  ###
  Recursive core of getChildren

  @param {GomNode} node The parent
  @param {string[]} [childTagNames]
  @param {string[]} [classNames]
  @param {boolean} [isChild=false]
  @param {GomNode[]} foundChildren The array, by reference, to contain all matches. Returned by getChildren()
  ###
  _getChildren = (node, childTagNames, classNames, foundChildren, isChild = false) ->
    if node and isChild and _isNodeMatch node, childTagNames, classNames
      foundChildren.push node

    children = node.children
    if children
      for child in children
        _getChildren child, childTagNames, classNames, foundChildren, IS_CHILD

    return

  ###
  Does given node match given search parameters? If tag or
  class names are not given, it's not a condition. If it
  tag names are given, the tag name must occur in that list.
  If class names are given, all class names of node must
  appear in that list.

  @param {GomNode} node The parent
  @param {string[]} [tagNames]
  @param {string[]} [classNames]
  @returns {boolean}
  ###
  _isNodeMatch = (node, tagNames, classNames) ->
    if tagNames
      if tagNames.indexOf(node.tag) is NOT_FOUND
        return false

    if classNames
      nodeClass = node.attributes?.class
      unless nodeClass?
        return false
      for c in classNames
        if nodeClass.indexOf(c) is NOT_FOUND
          return false

    return true

  ###
  @param {GomNode} [node]
  @param {string} key
  @param {any} val
  @returns {GomNode} node
  ###
  setAttribute = (node, key, val) ->
    if isNode node
      node.attributes ?= {}
      node.attributes[key] = val
    return node

  ###
  @param {GomNode} [node]
  @param {string} key
  @returns {any}
  ###
  getAttribute = (node, key) ->
    return node?.attributes?[key]

  ###
  Mixin the two objects into a new object.

  Values are copied by reference from arrays. Deep clone otherwise.
  The attributes1 values are preferred over the other if one must be chosen.
  If the flag allows it, strings that are different are concatenated with a space.
  If either side is an array, the result is the concat of the two values.

  @param {Object} [attributes1={}]
  @param {Object} [attributes2={}]
  @param {string[]} [exclusions=[]]
  @param {boolean} [concatString=false]
  @returns {Object} Should have all non-excluded keys from both objects, regardless
  ###
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

  ###
  Given two arrays, returns a fresh array using concat() so
  it contains all elements (by reference) of either array.
  If one side is not an array, it is wrapped in one before
  the concat().

  @param {any|any[]} [children1=[]]
  @param {any|any[]} [children2=[]]
  @returns {any[]}
  ###
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
