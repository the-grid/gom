module.exports = do ->

  create_gom_node = (tag, attributes, children) ->
    if attributes?.children
      children = attributes.children
      delete attributes.children
    else if children? and children not instanceof Array
      children = [children]

    return {
      _class: 'gom_node'

      attributes
      children
      tag: tag || 'div'
    }

  return create_gom_node
