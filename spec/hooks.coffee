minify = require('html-minifier').minify unless minify
chai = require 'chai' unless chai
GOM = require '../index' unless GOM

{expect,assert} = chai

expectHTML = (gom,html) ->
  renderer = GOM()
  expect(renderer.render(gom))
  .to
  .equal minify( html, {collapseWhitespace:true, keepClosingSlash:true}) # dangerous!!

toHTML = (name,gom,html) ->
  it name, ->
    expectHTML gom, html


#  _   _             _
# | | | | ___   ___ | | _____
# | |_| |/ _ \ / _ \| |/ / __|
# |  _  | (_) | (_) |   <\__ \
# |_| |_|\___/ \___/|_|\_\___/
#

describe "hooks", ->

  describe 'basics', ->

    $ = GOM(
      "post": (attributes, children) ->
        {title} = attributes.data
        unless title
          throw new Error 'Missing post title'
        return @ 'div', {class:['post']}, title
    )

    it 'works', ->

      node = $ 'post', {data:{title:'Tis a post!'}}

      expectHTML node,
        """
          <div class="post">Tis a post!</div>
        """

    it 'fails with missing data', ->

      expect(-> $('post', {data:{}})).to.throw Error

  describe 'hooks with merges', ->

    $ = GOM(

      "cta": (attributes={}, children) ->
        attributes = @mergeAttributes(attributes,{class:['cta']})
        return @ 'button', attributes, children

      "post": (attributes={}, children) ->
        {title,subtitle} = attributes.data

        defaultPostattributes = { class:['post'], style:{'color':'red',opacity:0}, index: 'cover' }

        attributes = @mergeAttributes(attributes, defaultPostattributes)

        postChildren = [
          @ "h1", {}, title
          @ "h2", {}, subtitle
        ]
        children = @mergeChildren(postChildren,children)

        return @ 'article', attributes, children
    )

    it '1 level', ->
      build = ->
        $ 'post', {class:['featured'], style:{opacity:1}, data:{title:'Tis a post!',subtitle:'indeed it is'}},
          [
            $ 'cta', {class:['active']}, 'Buy Now'
          ]
      expectHTML build(),
        """
          <article class="featured post" style="color:red; opacity:1;" index="cover">
            <h1>Tis a post!</h1>
            <h2>indeed it is</h2>
            <button class="active cta">Buy Now</button>
          </article>
        """

    it 'recursed', ->
      build = ->
        $ 'post', {class:['featured'], data:{title:'Tis a post!',subtitle:'indeed it is'}},
          [
            $ 'cta', {class:['active']}, 'Buy Now'
            $ 'post', {data:{title:'Tis an inner post!',subtitle:'indeed it is'}, style:{"color":"blue"}}
          ]
      expectHTML build(),
        """
          <article class="featured post" style="color:red; opacity:0;" index="cover">
            <h1>Tis a post!</h1>
            <h2>indeed it is</h2>
            <button class="active cta">Buy Now</button>
            <article style="color:blue; opacity:0;" class="post" index="cover">
              <h1>Tis an inner post!</h1>
              <h2>indeed it is</h2>
            </article>
          </article>
        """

    it 'with attributes duplication in merge', ->
      build = ->
        $ 'post', {class:['featured'], data:{title:'Tis a post!',subtitle:'indeed it is'}, index: "cover"},
          [
            $ 'cta', {class:['active']}, 'Buy Now'
            $ 'post', {data:{title:'Tis an inner post!',subtitle:'indeed it is'}, style:{"color":"blue"}}
          ]
      expectHTML build(),
        """
          <article class="featured post" index="cover" style="color:red; opacity:0;">
            <h1>Tis a post!</h1>
            <h2>indeed it is</h2>
            <button class="active cta">Buy Now</button>
            <article style="color:blue; opacity:0;" class="post" index="cover">
              <h1>Tis an inner post!</h1>
              <h2>indeed it is</h2>
            </article>
          </article>
        """

  describe 'hooks > includes & extends w/ blocks', ->

    $ = GOM(

      "layout": (attributes, children="", {footer}) ->

        @ "html", {}, [
          @ "head"
          @ "body", {}, [
            children
            @ "footer", {}, [
              footer
            ]
          ]
        ]

      "page-layout": (attributes, children) ->

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

      build = ->
        $ "page-layout", {},
          [
            $ "article", {}, "page 1 article 1"
          ]

      expectHTML build(),
        """
          <html>
            <head>
            </head>
            <body>
              <header class="page-header"></header>
              <article>page 1 article 1</article>
              <footer><a>In da footah</a></footer>
            </body>
          </html>
        """
