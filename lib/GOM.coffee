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

  $ = (tag, attributes, children, rest...) ->
    hook = hooks[tag]
    return hook.apply $, [attributes, children, rest...] if hook
    return new Node tag, attributes, children
  
  $.registerHook = (tag, cb) ->
    hooks[tag] = cb
  
  $.notAttr = ['children','data']
  $.emptyTags = ['br','hr','meta','link','base','img','embed','param','area','col','input']
    
  require('./mixins/helpers')($)
  require('./mixins/render')($)
  require('./mixins/transform')($)

  class Node

    constructor: (tag,attributes,children)->
      tag or tag='div'
      #attributes or attributes={}
      #children or children=[]
      @tag = tag

      if attributes
        @attributes = attributes
        #@attributes.class or @attributes.class = []

      if attributes?.children
        children = attributes.children
        delete attributes.children
      else if children? and !(children instanceof Array)
        children = [children]

      @children = children if children

      @

  return $