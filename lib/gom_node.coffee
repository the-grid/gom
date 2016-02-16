module.exports = do ->

  ###
  Returns one node in a GOM tree

  @param {string} tag
  @param {Object} [attributes]
  @param {Object[]} [children] Overridden by attributes.children if it exists
  @returns {Object}
  ###
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
