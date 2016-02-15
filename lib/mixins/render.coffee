# render mixin

module.exports = ($) ->

  {
    NOT_ATTR
    EMPTY_TAGS
  } = require './helpers'

  $.render = render = (nodes, parent) ->
    return _render nodes, parent if !(nodes instanceof Array)
    result = ""
    for node in nodes
      result += _render node, parent
    result

  _render = (node, parent) ->
    return '' if !node
    return node if typeof node is 'string'
    return render node if node instanceof Array
    return render node(parent) if typeof node is 'function'

    {tag,attributes,children} = node

    # in case JSON passed
    tag or tag='div'
    attributes or attributes={}
    children or children=[]

    return "" if !tag
    return """<#{tag}#{_renderAttr(attributes)}/>""" if EMPTY_TAGS.indexOf(tag) >= 0
    return """<#{tag}#{_renderAttr(attributes)}>#{_renderChildren(children, node)}</#{tag}>"""

  _renderChildren = (children, parent) ->
    return '' if children?.length <= 0
    html = ''
    for child in children
      if typeof child is 'string'
        html += child
      else
        html += render child, parent
    return html

  _renderStyles = (o) ->
    return o unless typeof o is "object"
    style = ""
    for key, val of o
      val = String(val) if typeof val is 'number'
      style += key + ":" + val + "; "
    # remove last semi-colon and whitespace
    style = style.slice(0,style.length-2)
    return style.trim()

  _renderAttr = (o) ->
    attributes = ''
    return attributes if !o
    for key, val of o
      continue unless NOT_ATTR.indexOf(key) is -1
      if key is 'style'
        val = _renderStyles val
      else
        val = String(val) if typeof val is 'number'
      if val?.length > 0
        continue unless key in ['class','style'] or typeof val is 'string'
        attributes += " " + key + '="'
        if key is 'class' and val instanceof Array
          attributes += val.join(" ")
        else
          attributes += val
        attributes += '"'
    return attributes

  $