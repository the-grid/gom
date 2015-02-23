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
                                              


#  _____                     __                                    
# |_   _| __ __ _ _ __  ___ / _| ___  _ __ _ __ ___   ___ 
#   | || '__/ _` | '_ \/ __| |_ / _ \| '__| '_ ` _ \ / __|
#   | || | | (_| | | | \__ \  _| (_) | |  | | | | | |\__ \
#   |_||_|  \__,_|_| |_|___/_|  \___/|_|  |_| |_| |_||___/                           

describe "Transforms", ->

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