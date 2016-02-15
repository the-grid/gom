# render mixin

module.exports = do ->

  {
    NOT_ATTR
    EMPTY_TAGS
  } = require './helpers'

  render = (nodes, parent) ->
    if !(nodes instanceof Array)
      return _render nodes, parent
    result = ""
    for node in nodes
      result += _render node, parent
    result

  _render = (node, parent) ->
    if !node
      return ''
    if typeof node is 'string'
      return node
    if node instanceof Array
      return render node
    if typeof node is 'function'
      return render node(parent)

    {tag,attributes,children} = node

    # in case JSON passed
    tag or tag='div'
    attributes or attributes={}
    children or children=[]

    if !tag
      return ""
    if EMPTY_TAGS.indexOf(tag) >= 0
      return """<#{tag}#{_renderAttr(attributes)}/>"""
    return """<#{tag}#{_renderAttr(attributes)}>#{_renderChildren(children, node)}</#{tag}>"""

  _renderChildren = (children, parent) ->
    if children?.length <= 0
      return ''
    html = ''
    for child in children
      if typeof child is 'string'
        html += child
      else
        html += render child, parent
    return html

  _renderStyles = (o) ->
    unless typeof o is "object"
      return o
    style = ""
    for key, val of o
      if typeof val is 'number'
        val = String(val)
      style += key + ":" + val + "; "
    # remove last semi-colon and whitespace
    style = style.slice(0,style.length-2)
    return style.trim()

  _renderAttr = (o) ->
    attributes = ''
    if !o
      return attributes
    for key, val of o
      unless NOT_ATTR.indexOf(key) is -1
        continue
      if key is 'style'
        val = _renderStyles val
      else
        if typeof val is 'number'
          val = String(val)
      if val?.length > 0
        unless key in ['class','style'] or typeof val is 'string'
          continue
        attributes += " " + key + '="'
        if key is 'class' and val instanceof Array
          attributes += val.join(" ")
        else
          attributes += val
        attributes += '"'
    return attributes

  return render
