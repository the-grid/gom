# render mixin

module.exports = do ->

  {
    NOT_ATTR
    EMPTY_TAGS
  } = require './helpers'

  NOT_FOUND = -1


  render = (nodes, parent) ->
    if nodes instanceof Array
      return _render_nodes nodes, parent
    return _render_node nodes, parent

  _render_nodes = (nodes, parent) ->
    result = ''
    for node in nodes
      result += render node, parent
    return result

  _render_node = (node, parent) ->
    switch typeof node
      when 'undefined'
        return ''
      when 'string'
        return node
      when 'function'
        return render node parent
    if node is null
      return ''

    {
      tag
      attributes
      children
    } = node

    # in case JSON passed
    tag ||= 'div'
    attributes ||= {}
    children ||= []

    attr = _renderAttr attributes
    if EMPTY_TAGS.indexOf(tag) isnt NOT_FOUND
      return "<#{tag}#{attr}/>"

    body = _renderChildren children, node
    return "<#{tag}#{attr}>#{body}</#{tag}>"

  _renderChildren = (children, parent) ->
    html = ''
    for child in children
      html += render child, parent
    return html

  _renderStyles = (o) ->
    unless typeof o is 'object'
      return o
    style = ''
    for key, val of o
      style += "#{key}:#{val}; "
    # remove last semi-colon and whitespace
    return style.slice 0, -2

  _renderAttr = (attrs) ->
    attributes = ''
    for key, val of attrs
      if NOT_ATTR.indexOf(key) is NOT_FOUND
        if key is 'style'
          val = _renderStyles val
        else if key is 'class' and val instanceof Array
          val = val.join ' '
        else if typeof val is 'number'
          val = String val

        if typeof val is 'string' # and val.length isnt 0
          attributes += " #{key}=\"#{val}\""
    return attributes

  return render
