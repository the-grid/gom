minify = require('html-minifier').minify unless minify
chai = require 'chai' unless chai
try
  GOM = require '../index'
catch e
  GOM = require 'gom'

{expect,assert} = chai

expectHTML = (gom,html) ->
  renderer = GOM()
  expect(renderer.render(gom))
  .to
  .equal minify( html, {collapseWhitespace:true, keepClosingSlash:true}) # dangerous!!

toHTML = (name,gom,html) ->
  it name, ->
    expectHTML gom, html


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
                                                 
describe "GOM", ->

  describe "basics", ->

    $ = GOM()

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



#  _____                     __                                    
# |_   _| __ __ _ _ __  ___ / _| ___  _ __ _ __ ___   ___ _ __ ___ 
#   | || '__/ _` | '_ \/ __| |_ / _ \| '__| '_ ` _ \ / _ \ '__/ __|
#   | || | | (_| | | | \__ \  _| (_) | |  | | | | | |  __/ |  \__ \
#   |_||_|  \__,_|_| |_|___/_|  \___/|_|  |_| |_| |_|\___|_|  |___/                           

describe "Transformers", ->

  describe 'wrapping', ->

    $ = GOM()

    tree = [
      $ 'section', null, [
        $ 'article', null, [
          $ 'p', null, [
            "hello, I am "
            $ 'a', {}, "Molly"
            "!"
          ]
        ]
        $ 'article', null, [
          $ 'p', null, [
            "hello, I am "
            $ 'a', {}, "Molly"
            "!"
          ]
        ]
      ]
      $ 'a', {}, "Molly"
      " rocks!"
    ]

    it 'wrap link tags / renders html', ->
      tree = $.transform tree, [
        "a": (node) ->
          return $ 'span', {class:['wrap']}, [node]
      ]
      expectHTML tree,
        """
          <section>
            <article>
              <p>hello, I am <span class="wrap"><a>Molly</a></span>!</p>
            </article>
            <article>
              <p>hello, I am <span class="wrap"><a>Molly</a></span>!</p>
            </article>
          </section>
          <span class="wrap"><a>Molly</a></span> rocks!
        """

    it 'unwrap link tags / renders html', ->
      transformations = [
        "span": (node) ->
          return node unless 'wrap' in node.attributes.class
          {children} = node
          children or children = []
          linkNode = null
          for child in children
            if child.tag is 'a'
              linkNode = child
              break
          return linkNode if linkNode
          return node
      ]
      tree = $.transform(tree, transformations)
      expectHTML tree,
        """
          <section>
            <article>
              <p>hello, I am <a>Molly</a>!</p>
            </article>
            <article>
              <p>hello, I am <a>Molly</a>!</p>
            </article>
          </section>
          <a>Molly</a> rocks!
        """

    it 'only wrap <a> that are descdents of <article>', ->
      tree = $.transform tree, [
        (node) ->
          return node unless node.tag is 'article'
          return $.transform node, [
            "a": (node) ->
              return $ 'span', {class:['wrap']}, [node]
          ]
      ]
      expectHTML tree,
        """
          <section>
            <article>
              <p>hello, I am <span class="wrap"><a>Molly</a></span>!</p>
            </article>
            <article>
              <p>hello, I am <span class="wrap"><a>Molly</a></span>!</p>
            </article>
          </section>
          <a>Molly</a> rocks!
        """

  describe 'custom tag transformers', ->

    $ = GOM()

    test = (transformations) ->

      tree = null

      it 'builds ast', ->
        tree = $ 'post', {data:{title:'Tis parent post!'}},
          [
            $ 'post', {data:{title:'Tis child post!'}}
          ]

        expect(tree).to.eql
          tag: 'post'
          attributes:data:{title:'Tis parent post!'}
          children:
            [
              tag: 'post'
              attributes:data:{title:'Tis child post!'}
            ]

      it 'transforms ast', ->
        tree = $.transform tree, transformations
        expect(tree).to.eql
          children:
            [
                'Tis parent post!'
              ,
                children:
                  [
                    'Tis child post!'
                  ]
                tag: 'div'
                attributes:class:['post']
            ]
          tag: 'div'
          attributes:class:['post']


      it 'renders html', ->
        expectHTML tree,
          """
            <div class="post">Tis parent post!<div class="post">Tis child post!</div></div>
          """

    describe "callback transformation", ->
      test [
        (node) ->
          return node unless node.tag is 'post'
          {attributes, children} = node
          children or children = []
          return @ 'div', {class:['post']}, [attributes?.data?.title].concat children
      ]

    describe "key-val selector transformation", ->
      test [
        "post": ({attributes,children}) ->
          children or children = []
          return @ 'div', {class:['post']}, [attributes?.data?.title].concat children
      ]

    #it 'fails with missing data', ->
    #
    #  expect(-> $('post', {data:{}})).to.throw Error