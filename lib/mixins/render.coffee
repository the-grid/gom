###
Renderer methods for GOM tree
Takes a node and generates an html string
###

module.exports = do ->

  {
    NOT_ATTR
    EMPTY_TAGS
  } = require './helpers'

  NOT_FOUND = -1

  ###
  Create html from the GOM

  @param {GomNode|GomNodes} nodes
  @param {GomNode} [parent] Not used by this class but will be passed on to custom node renderer callbacks
  @returns {string}
  ###
  render = (nodes, parent) ->
    if nodes instanceof Array
      return _render_nodes nodes, parent
    return _render_node nodes, parent

  ###
  @param {GomNodes[]} nodes
  @param {GomNode} [parent]
  @returns {string}
  ###
  _render_nodes = (nodes, parent) ->
    result = ''
    for node in nodes
      result += render node, parent
    return result

  ###
  Render one GOM node and all its children to html.

  @param {GomNodes|string|Function} [node] If null/undefined, returns ''. If string, returns that string. If function, returns `render(node(parent))`
  @param {GomNode} [parent] If the node is a function, this value is passed on to the call as well.
  @returns {string}
  ###
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

  ###
  @param {GomNode[]} children
  @param {GomNode} [parent]
  @returns {string}
  ###
  _renderChildren = (children, parent) ->
    html = ''
    for child in children
      html += render child, parent
    return html

  ###
  Create the style attribute value as a string.
  Basically maps keys and values of given object
  to "css style" pairs.

  @param {Object} o If not an object, returns o
  @returns {string} `key:value; key:value; ...'
  ###
  _renderStyles = (o) ->
    unless o and typeof o is 'object'
      return o
    style = ''
    for key, val of o
      style += "#{key}:#{val}; "
    # remove last semi-colon and whitespace
    return style.slice 0, -2

  ###
  Convert given object of attributes to spaced `key="value"` pairs
  A key is skipped if it is in the NOT_ATTR list.
  A key is also skipped if it is not a string or number. Exception
  for "class", which can be an array.

  @param {Object} attrs
  @returns {string} ` key="value" key="value" ...`
  ###
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
