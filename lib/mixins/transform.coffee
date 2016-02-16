module.exports = do ->

  ###
  Transform GOM tree with custom transform functions and return
  a new structure. You can supply multiple transform functions
  which are called in serial, each getting the result of the
  previous transformation. The final result is put back. So the
  returned tree has the same "form" as the original.

  @param {GomNode|GomNode[]} nodes
  @param {Function|Function[]} transform Should accept a GomNode, its parent, and return some object to replace the node
  @param {...} args The remainder args, like parent, are passed on directly to the transformation functions and unused otherwise
  @returns {Object} same tree structure, values depend on the transformation functions
  ###
  transform = (nodes, transforms, args...) ->
    unless transforms instanceof Array
      transforms = [transforms]
    return _transform nodes, transforms, args

  ###
  This abstraction assumes `transformations` is an array

  @see transform
  @param {GomNode|GomNode[]} nodes
  @param {Function[]} transform Should accept a GomNode, its parent, and return some object to replace the node
  @param {...} args The remainder args, like parent, are passed on directly to the transformation functions and unused otherwise
  @returns {Object} same tree structure, values depend on the transformation functions
  ###
  _transform = (nodes, transforms, args) ->
    # return if falsy child
    unless nodes?
      return nodes

    if nodes instanceof Array
      return _transformNodes nodes, transforms, args

    # if child is function, evaluate it
    if typeof node is 'function'
      return _transform node(), transforms, args

    return _transformNode nodes, transforms, args

  ###
  This abstraction assumes `nodes` is an array

  @see transform
  @param {GomNode[]} nodes
  @param {Function|Function[]} transform Should accept a GomNode, its parent, and return some object to replace the node
  @param {...} args The remainder args, like parent, are passed on directly to the transformation functions and unused otherwise
  @returns {Object} same tree structure, values depend on the transformation functions
  ###
  _transformNodes = (nodes, transforms, args) ->
    newNodes = []
    for node in nodes
      newNode = _transform node, transforms, args
      # removes falsy children
      if newNode
        newNodes.push newNode
    return newNodes

  ###
  Transform one node with an array of transform functions.

  @see transform
  @param {GomNode} nodes
  @param {Function[]} transform Should accept a GomNode, its parent, and return some object to replace the node
  @param {...} args The remainder args, like parent, are passed on directly to the transformation functions and unused otherwise
  @returns {Object} same tree structure, values depend on the transformation functions
  ###
  _transformNode = (node, transforms, args) ->

    # Pass transforms & parent element to callback
    args = args?.slice() || [args]
    unless args.length
      args.push null # ensure the "parent" arg space
    args.unshift node
    args.push transforms
    # recurse children first
    # otherwise wrapping transforms = infinite loop
    if node.children?
      node.children = transform node.children, transforms, node

    for t in transforms
      if typeof t is 'function'
        node = t.apply null, args
      else if typeof t is 'object'
        for selector, callback of t
          if node.tag is selector
            node = callback.apply null, args

    return node

  return transform
