chai = require 'chai' unless chai
try
  DOM = require '../index'
catch e
  DOM = require 'gom'

expect = chai.expect

describe "DOM", ->


  describe "basics", ->

    $ = DOM()

    it '<div>', ->
      node = $ 'div'
      expect($.render(node)).to.equal """<div></div>"""

    it 'defaults', ->
      node = $ null, null, 'hello world'
      expect($.render(node)).to.equal """<div>hello world</div>"""

    it '<div>hello world</div>', ->
      node = $ 'div', {}, ['hello world']
      expect($.render(node)).to.equal """<div>hello world</div>"""

    it '<div class="hello" data-foo="bar">', ->
      node = $ 'div',
        class:['hello']
        'data-foo':'bar'
      expect($.render(node)).to.equal """<div class="hello" data-foo="bar"></div>"""

    it 'child by attrs.children', ->
      child = $ 'div',
        id: 'baby'
        class:['child thing']
      node = $ 'div',
        id: 'mommy'
        class:['parent thing']
        children:[child]
      expect($.render(node)).to.equal """<div id="mommy" class="parent thing"><div id="baby" class="child thing"></div></div>"""

    it '3 level child by children param', ->
      node = $ "section", {id:'grand'},
        [
          $ "article", {id:'mommy', class:['parent thing']},
            [
              $ "span", {id:'baby', class:['child thing']}
            ]
        ]
      expect($.render(node)).to.equal """<section id="grand"><article id="mommy" class="parent thing"><span id="baby" class="child thing"></span></article></section>"""

    it 'child by append', ->
      node = $ 'div',
        id: 'mommy'
        class:['parent thing']
      $.append node, $ 'div',
        id: 'baby'
        class:['child thing']
      expect($.render(node)).to.equal """<div id="mommy" class="parent thing"><div id="baby" class="child thing"></div></div>"""

    it 'mixed children', ->
      node = $ "a", {href:'google.com'}, ["this is ",$("span",{},"awesome"),"... for reals!"]
      expect($.render(node)).to.equal """<a href="google.com">this is <span>awesome</span>... for reals!</a>"""

    it 'render node array', ->
      nodes = [
        $ "head"
        $ "body"
      ]
      expect($.render(nodes)).to.equal """<head></head><body></body>"""

    it 'ignore nested children arrays', ->

      render = ->
        $ "section", {}, [
          [[[$ "div", id:1]]]
          [[$ "div", id:2]]
          [$ "div", id:3]
          $ "div", {id:4}
        ]
      expect($.render(render())).to.equal """<section><div id="1"></div><div id="2"></div><div id="3"></div><div id="4"></div></section>"""

    it 'empty tags', ->

      render = ->
        [
          $ "img", {class:['img']}
          $ "hr", {class:['hr']}
          $ "input", {class:['input']}
        ]
      expect($.render(render())).to.equal """<img class="img"/><hr class="hr"/><input class="input"/>"""


  describe "hooks", ->

    describe 'basics', ->

      $ = DOM(
        "post": (attrs, children) ->
          {title} = attrs.data
          unless title
            throw new Error 'Missing post title'
          return @ 'div', {class:['post']}, title
      )

      it 'works', ->

        node = $ 'post', {data:{title:'Tis a post!'}}

        expect($.render(node)).to.equal """<div class="post">Tis a post!</div>"""

      it 'fails with missing data', ->

        expect(-> $('post', {data:{}})).to.throw Error

    describe 'hooks with merges', ->

      $ = DOM(

        "cta": (attrs={}, children) ->
          attrs = @mergeAttrs({class:['cta']},attrs)
          return @ 'button', attrs, children

        "post": (attrs={}, children) ->
          {title,subtitle} = attrs.data

          attrs = @mergeAttrs({class:['post']},attrs)

          postChildren = [
            @ "h1", {}, title
            @ "h2", {}, subtitle
          ]
          children = @mergeChildren(postChildren,children)

          return @ 'article', attrs, children
      )

      it '1 level', ->

        render = ->
          $ 'post', {class:['featured'], data:{title:'Tis a post!',subtitle:'indeed it is'}},
            [
              $ 'cta', {class:['active']}, 'Buy Now'
            ]

        expect($.render(render())).to.equal """<article class="post featured"><h1>Tis a post!</h1><h2>indeed it is</h2><button class="cta active">Buy Now</button></article>"""

      it 'recursed', ->

        render = ->
          $ 'post', {class:['featured'], data:{title:'Tis a post!',subtitle:'indeed it is'}},
            [
              $ 'cta', {class:['active']}, 'Buy Now'
              $ 'post', {data:{title:'Tis an inner post!',subtitle:'indeed it is'}}
            ]

        expect($.render(render())).to.equal """<article class="post featured"><h1>Tis a post!</h1><h2>indeed it is</h2><button class="cta active">Buy Now</button><article class="post"><h1>Tis an inner post!</h1><h2>indeed it is</h2></article></article>"""



    describe 'hooks > includes & extends w/ blocks', ->

      $ = DOM(

        "layout": (attrs, children="", {footer}) ->

          @ "html", {}, [
            @ "head"
            @ "body", {}, [
              children
              @ "footer", {}, [
                footer
              ]
            ]
          ]

        "page-layout": (attrs, children) ->

          @ "layout", {},
            [
              @ "header", {class:['page-header']}
              children
            ],
            footer:
              [
                @ "a", {}, "In da footah"
              ]


      )

      it "works", ->

        render = ->
          $ "page-layout", {},
            [
              $ "article", {}, "page 1 article 1"
            ]

        expect($.render(render())).to.equal """<html><head></head><body><header class="page-header"></header><article>page 1 article 1</article><footer><a>In da footah</a></footer></body></html>"""


