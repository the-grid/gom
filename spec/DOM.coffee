minify = require('html-minifier').minify unless minify
chai = require 'chai' unless chai
try
  DOM = require '../index'
catch e
  DOM = require 'gom'

expect = chai.expect

expectHTML = (gom,html) ->
  renderer = DOM()
  expect(renderer.render(gom))
  .to
  .equal minify( html, {collapseWhitespace:true, keepClosingSlash:true}) # dangerous!!

toHTML = (name,gom,html) ->
  it name, ->
    expectHTML gom, html

describe "DOM", ->

  describe "basics", ->

    $ = DOM()

    toHTML '<div>',
      $ 'div'
      "<div></div>"

    toHTML 'defaults',
      $ null, null, 'hello world'
      """
        <div>hello world</div>
      """

    toHTML '<div>hello world</div>',
      $ 'div', {}, ['hello world']
      """
        <div>hello world</div>
      """

    toHTML '<div class="hello" data-foo="bar">',
      $ 'div',
        class:['hello']
        'data-foo':'bar'
      """
        <div class="hello" data-foo="bar"></div>
      """

    it 'child by attributes.children', ->
      child = $ 'div',
        id: 'baby'
        class:['child thing']
      node = $ 'div',
        id: 'mommy'
        class:['parent thing']
        children:[child]
      expectHTML node, 
        """
          <div id="mommy" class="parent thing">
            <div id="baby" class="child thing"></div>
          </div>
        """

    it '3 level child by children param', ->
      node = $ "section", {id:'grand'},
        [
          $ "article", {id:'mommy', class:['parent thing']},
            [
              $ "span", {id:'baby', class:['child thing']}
            ]
        ]
      expectHTML node, 
        """
          <section id="grand">
            <article id="mommy" class="parent thing">
              <span id="baby" class="child thing"></span>
            </article>
          </section>
        """

    it 'child by append', ->
      node = $ 'div',
        id: 'mommy'
        class:['parent thing']
      $.append node, $ 'div',
        id: 'baby'
        class:['child thing']
      expectHTML node, 
        """
          <div id="mommy" class="parent thing">
            <div id="baby" class="child thing"></div>
          </div>
        """

    it 'mixed children', ->
      node = $ "a", {href:'google.com'}, ["this is ",$("span",{},"awesome"),"... for reals!"]
      expectHTML node, 
        """
          <a href="google.com">this is <span>awesome</span>... for reals!</a>
        """

    it 'render node array', ->
      nodes = [
        $ "head"
        $ "body"
      ]
      expectHTML nodes, 
        """
          <head></head>
          <body></body>
        """

    it 'ignore nested children arrays', ->
      build = ->
        $ "section", {}, [
          [[[$ "div", id:1]]]
          [[$ "div", id:2]]
          [$ "div", id:3]
          $ "div", {id:4}
        ]
      expectHTML build(), 
        """
          <section><div id="1"></div><div id="2"></div><div id="3"></div><div id="4"></div></section>
        """

    it 'ignore falsey children', ->

      build = ->
        $ "section", {}, [
          [null]
          [[null]]
          $ "div"
          null
          [[undefined]]
        ]
      expectHTML build(), 
        """
          <section>
            <div></div>
          </section>
        """


    it 'empty tags', ->
      build = ->
        [
          $ "img", {class:['img']}
          $ "hr", {class:['hr']}
          $ "input", {class:['input']}
        ]
      expectHTML build(),
        """
          <img class="img"/>
          <hr class="hr"/>
          <input class="input"/>
        """


    it 'functional children', ->

      build = ->
        [
          ->
            $ "img", {class:['img']}
          [
            ->
              $ "hr", {class:['hr']}
          ]
          ->
            html = ""
            for str in ["hello","functional","offspring"]
              html += " " + str
            html.trim()

        ]
      expectHTML build(), 
        """
          <img class="img"/>
          <hr class="hr"/>hello functional offspring
        """


    it 'object children', ->
      # Useful for parsing HTML to GOM JSON
      build = ->
        [
          {
            tag: 'div'
            attributes:
              class:['box']
              style:
                color: 'red'
              'data-special': 'sauce'
            children: [
              {
                tag: 'img'
                attributes:
                  class: ['cover']
              }
            ]
          }
          ->
            {
              tag: 'section'
            }

        ]
      expectHTML build(), 
        """
          <div class="box" style="color:red;" data-special="sauce">
            <img class="cover"/>
          </div>
          <section></section>
        """


    it 'style attribute', ->
      build = ->
        [
          $ "div", {id:'styled',style:{'background-color':"blue",'color':"hsl(0,0%,0%)", "line-height":1.5}}
        ]
      expectHTML build(), 
        """
          <div id="styled" style="background-color:blue; color:hsl(0,0%,0%); line-height:1.5;"></div>
        """


  describe "hooks", ->

    describe 'basics', ->

      $ = DOM(
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

      $ = DOM(

        "cta": (attributes={}, children) ->
          attributes = @mergeattributes(attributes,{class:['cta']})
          return @ 'button', attributes, children

        "post": (attributes={}, children) ->
          {title,subtitle} = attributes.data

          defaultPostattributes = { class:['post'], style:{'color':'red',opacity:0} }

          attributes = @mergeattributes(attributes, defaultPostattributes)

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
            <article class="featured post" style="color:red; opacity:1;">
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
            <article class="featured post" style="color:red; opacity:0;">
              <h1>Tis a post!</h1>
              <h2>indeed it is</h2>
              <button class="active cta">Buy Now</button>
              <article style="color:blue; opacity:0;" class="post">
                <h1>Tis an inner post!</h1>
                <h2>indeed it is</h2>
              </article>
            </article>
          """
    describe 'hooks > includes & extends w/ blocks', ->

      $ = DOM(

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


