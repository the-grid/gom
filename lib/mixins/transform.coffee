module.exports = ($) ->

  $.transform = transform = (nodes, transforms) ->
    transforms = [transforms] unless transforms instanceof Array
    return _transform nodes, transforms

  _transform = (nodes, transformations) ->
    # return if falsy child
    return nodes unless nodes?

    return _transformNodes(nodes, transformations) if nodes instanceof Array

    # if child is function, evaluate it
    return _transform(node(), transformations) if typeof node is 'function'

    return _transformNode nodes, transformations

  _transformNodes = (nodes, transformations) ->
    newNodes = []
    for node in nodes
      newNode = _transform node, transformations
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

  $