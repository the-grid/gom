module.exports = ($) ->

  $.transform = transform = (nodes, transforms) ->
    transforms = [transforms] unless transforms instanceof Array
    return _transform nodes, transforms

  _transform = (nodes, transforms) ->
    # return if falsy child
    return nodes unless nodes?

    return _transformNodes(nodes, transforms) if nodes instanceof Array

    # if child is function, evaluate it
    return _transform(node(), transforms) if typeof node is 'function'

    return _transformNode nodes, transforms

  _transformNodes = (nodes, transforms) ->
    newNodes = []
    for node in nodes
      newNode = _transform node, transforms
      # removes falsy children
      newNodes.push(newNode) if newNode
    newNodes

  _transformNode = (node, transforms) ->

    # recurse children first
    # otherwise wrapping transforms = infinite loop
    if node.children?
      node.children = transform node.children, transforms

    for t in transforms

      if typeof t is 'function'
        node = t.call $, node

      else if typeof t is 'object'
        for selector, callback of t
          node = callback.call($,node) if node.tag is selector

    node

  $