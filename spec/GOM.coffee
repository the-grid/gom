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
