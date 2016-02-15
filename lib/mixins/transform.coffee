module.exports = ($) ->

  $.transform = transform = (nodes, transforms, args...) ->
    unless transforms instanceof Array
      transforms = [transforms]
    return _transform nodes, transforms, args

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

  _transformNodes = (nodes, transforms, args) ->
    newNodes = []
    for node in nodes
      newNode = _transform node, transforms, args
      # removes falsy children
      if newNode
        newNodes.push newNode
    return newNodes

  _transformNode = (node, transforms, args) ->

    # Pass transforms & parent element to callback
    args = args?.slice() || [args]
    unless args.length
      args.push null
    args.unshift node
    args.push transforms
    # recurse children first
    # otherwise wrapping transforms = infinite loop
    if node.children?
      node.children = transform node.children, transforms, node

    for t in transforms

      if typeof t is 'function'
        node = t.apply $, args

      else if typeof t is 'object'
        for selector, callback of t
          if node.tag is selector
            node = callback.apply $, args

    return node

  return $
