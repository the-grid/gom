module.exports = do ->

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

      if children
        @children = children

  return Node
