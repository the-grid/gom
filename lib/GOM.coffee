#          _              _            _   _
#         /\ \           /\ \         /\_\/\_\ _
#        /  \ \         /  \ \       / / / / //\_\
#       / /\ \_\       / /\ \ \     /\ \/ \ \/ / /
#      / / /\/_/      / / /\ \ \   /  \____\__/ /
#     / / / ______   / / /  \ \_\ / /\/________/
#    / / / /\_____\ / / /   / / // / /\/_// / /
#   / / /  \/____ // / /   / / // / /    / / /
#  / / /_____/ / // / /___/ / // / /    / / /
# / / /______\/ // / /____\/ / \/_/    / / /
# \/___________/ \/_________/          \/_/

module.exports = (hooks={}) ->

  create_gom_node = require './gom_node'
  helpers = require './mixins/helpers'
  transform = require './mixins/transform'

  $ = (tag, attributes, children, rest...) ->
    hook = hooks[tag]
    if hook
      return hook.apply $, [attributes, children, rest...]
    return create_gom_node tag, attributes, children

  $.registerHook = (tag, cb) ->
    hooks[tag] = cb
    return

  $.notAttr = ['children','data']
  $.emptyTags = ['br','hr','meta','link','base','img','embed','param','area','col','input']

  # could do this;
  # for key of helpers
  #   $[key] = helpers[key]
  # but being explicit makes for easier debugging, so:

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

  require('./mixins/render')($)

  $.transform = transform

  return $
