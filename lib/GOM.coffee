###          _              _            _   _
         /\ \           /\ \         /\_\/\_\ _
        /  \ \         /  \ \       / / / / //\_\
       / /\ \_\       / /\ \ \     /\ \/ \ \/ / /
      / / /\/_/      / / /\ \ \   /  \____\__/ /
     / / / ______   / / /  \ \_\ / /\/________/
    / / / /\_____\ / / /   / / // / /\/_// / /
   / / /  \/____ // / /   / / // / /    / / /
  / / /_____/ / // / /___/ / // / /    / / /
 / / /______\/ // / /____\/ / \/_/    / / /
 \/___________/ \/_________/          \/_/


Grid Object Model

A virtual DOM toolkit

###


###
Toolkit for creating gom node trees.
You can pass in a callback to handle specific tag names manually.
The returned function can create GOM nodes, and has static properties to manipulate GOM trees.

@param {Object} [hooks] A hash of callbacks per tag name. When defined for a tag, the callback should return the node.
@returns {Function} Similar to (BUT NOT) jquery's $
###
GOM = (hooks={}) ->

  create_gom_node = require './gom_node'
  helpers = require './mixins/helpers'
  transform = require './mixins/transform'
  render = require './mixins/render'

  ###
  Create a new GOM node. Optionally with predefined attributes and children.

  @param {string} tag
  @param {Object} [attributes]
  @param {Object[]} [children] Not GOM nodes, will be turned into them though
  @param {any[]} [rest] Additional parameters propagated to callbacks
  ###
  $ = (tag, attributes, children, rest...) ->
    hook = hooks[tag]
    if hook
      return hook.apply $, [attributes, children, rest...]
    return create_gom_node tag, attributes, children

  ###
  Register an additional callback for given tag name

  @param {string} tag
  @param {Function} cb
  ###
  $.registerHook = (tag, cb) ->
    hooks[tag] = cb
    return

  # could do this;
  # for key of helpers
  #   $[key] = helpers[key]
  # but being explicit makes for easier debugging, so:

  # TOFIX: do we need to expose these properties? or only used in ./render?
  $.notAttr = helpers.NOT_ATTR
  $.emptyTags = helpers.EMPTY_TAGS

  $.addClass = helpers.addClass
  $.append = helpers.append
  $.getAttribute = helpers.getAttribute
  $.getChildren = helpers.getChildren
  $.getFirstDescendant = helpers.getFirstDescendant
  $.hasClass = helpers.hasClass
  $.isNode = helpers.isNode
  $.mergeAttributes = helpers.mergeAttributes
  $.mergeChildren = helpers.mergeChildren
  $.prepend = helpers.prepend
  $.removeClass = helpers.removeClass
  $.setAttribute = helpers.setAttribute

  $.render = render
  $.transform = transform

  return $

module.exports = GOM
