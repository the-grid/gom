var GOM, assert, chai, expect, expectHTML, minify, toHTML,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

if (!minify) {
  minify = require('html-minifier').minify;
}

if (!chai) {
  chai = require('chai');
}

if (!GOM) {
  GOM = require('../index');
}

expect = chai.expect, assert = chai.assert;

expectHTML = function(gom, html) {
  var renderer;
  renderer = GOM();
  return expect(renderer.render(gom)).to.equal(minify(html, {
    collapseWhitespace: true,
    keepClosingSlash: true
  }));
};

toHTML = function(name, gom, html) {
  return it(name, function() {
    return expectHTML(gom, html);
  });
};

describe("Transforms", function() {
  describe('basics', function() {
    var $, getNode;
    $ = GOM();
    getNode = function() {
      return $('post', {
        "class": ['featured']
      });
    };
    it('by matching selector key', function() {
      var node;
      node = $.transform(getNode(), {
        'post': function(node) {
          node.tag = 'article';
          return node;
        }
      });
      return expectHTML(node, "<article class=\"featured\"></article>");
    });
    it('not by mismatching selector key', function() {
      var node;
      node = $.transform(getNode(), {
        'postttt': function(node) {
          node.tag = 'article';
          return node;
        }
      });
      return expectHTML(node, "<post class=\"featured\"></post>");
    });
    it('by callback', function() {
      var node;
      node = $.transform(getNode(), function(node) {
        node.tag = 'section';
        return node;
      });
      return expectHTML(node, "<section class=\"featured\"></section>");
    });
    it('by matching selector key w/ args', function() {
      var node, transform;
      transform = {
        'post': function(node, clazz) {
          node.tag = 'article';
          $.addClass(node, clazz);
          return node;
        }
      };
      node = $.transform(getNode(), transform, 'selected');
      return expectHTML(node, "<article class=\"featured selected\"></article>");
    });
    return it('by callback key w/ args', function() {
      var node, transform;
      transform = function(node, clazz1, clazz2) {
        node.tag = 'section';
        $.addClass(node, [clazz1, clazz2]);
        return node;
      };
      node = $.transform(getNode(), transform, 'foo', 'bar');
      return expectHTML(node, "<section class=\"featured foo bar\"></section>");
    });
  });
  describe('wrapping', function() {
    var $, tree;
    $ = GOM();
    tree = [$('section', null, [$('article', null, [$('p', null, ["hello, I am ", $('a', {}, "Molly"), "!"])]), $('article', null, [$('p', null, ["hello, I am ", $('a', {}, "Molly"), "!"])])]), $('a', {}, "Molly"), " rocks!"];
    it('wrap link tags / renders html', function() {
      tree = $.transform(tree, [
        {
          "a": function(node) {
            return this('span', {
              "class": ['wrap']
            }, [node]);
          }
        }
      ]);
      return expectHTML(tree, "<section>\n  <article>\n    <p>hello, I am <span class=\"wrap\"><a>Molly</a></span>!</p>\n  </article>\n  <article>\n    <p>hello, I am <span class=\"wrap\"><a>Molly</a></span>!</p>\n  </article>\n</section>\n<span class=\"wrap\"><a>Molly</a></span> rocks!");
    });
    it('unwrap link tags / renders html', function() {
      var transformations;
      transformations = [
        {
          "span": function(node) {
            var child, children, linkNode, _i, _len;
            if (__indexOf.call(node.attributes["class"], 'wrap') < 0) {
              return node;
            }
            children = node.children;
            children || (children = []);
            linkNode = null;
            for (_i = 0, _len = children.length; _i < _len; _i++) {
              child = children[_i];
              if (child.tag === 'a') {
                linkNode = child;
                break;
              }
            }
            if (linkNode) {
              return linkNode;
            }
            return node;
          }
        }
      ];
      tree = $.transform(tree, transformations);
      return expectHTML(tree, "<section>\n  <article>\n    <p>hello, I am <a>Molly</a>!</p>\n  </article>\n  <article>\n    <p>hello, I am <a>Molly</a>!</p>\n  </article>\n</section>\n<a>Molly</a> rocks!");
    });
    return it('only wrap <a> that are descdents of <article>', function() {
      tree = $.transform(tree, [
        function(node) {
          if (node.tag !== 'article') {
            return node;
          }
          return this.transform(node, [
            {
              "a": function(node) {
                return this('span', {
                  "class": ['wrap']
                }, [node]);
              }
            }
          ]);
        }
      ]);
      return expectHTML(tree, "<section>\n  <article>\n    <p>hello, I am <span class=\"wrap\"><a>Molly</a></span>!</p>\n  </article>\n  <article>\n    <p>hello, I am <span class=\"wrap\"><a>Molly</a></span>!</p>\n  </article>\n</section>\n<a>Molly</a> rocks!");
    });
  });
  describe('custom tag transformers', function() {
    var $, test;
    $ = GOM();
    test = function(transformations) {
      var tree;
      tree = null;
      it('builds ast', function() {
        tree = $('post', {
          data: {
            title: 'Tis parent post!'
          }
        }, [
          $('post', {
            data: {
              title: 'Tis child post!'
            }
          })
        ]);
        return expect(tree).to.eql({
          tag: 'post',
          attributes: {
            data: {
              title: 'Tis parent post!'
            }
          },
          children: [
            {
              tag: 'post',
              attributes: {
                data: {
                  title: 'Tis child post!'
                }
              }
            }
          ]
        });
      });
      it('transforms ast', function() {
        tree = $.transform(tree, transformations);
        return expect(tree).to.eql({
          children: [
            'Tis parent post!', {
              children: ['Tis child post!'],
              tag: 'div',
              attributes: {
                "class": ['post']
              }
            }
          ],
          tag: 'div',
          attributes: {
            "class": ['post']
          }
        });
      });
      return it('renders html', function() {
        return expectHTML(tree, "<div class=\"post\">Tis parent post!<div class=\"post\">Tis child post!</div></div>");
      });
    };
    describe("callback transformation", function() {
      return test([
        function(node) {
          var attributes, children, _ref;
          if (node.tag !== 'post') {
            return node;
          }
          attributes = node.attributes, children = node.children;
          children || (children = []);
          return this('div', {
            "class": ['post']
          }, [attributes != null ? (_ref = attributes.data) != null ? _ref.title : void 0 : void 0].concat(children));
        }
      ]);
    });
    return describe("key-val selector transformation", function() {
      return test([
        {
          "post": function(_arg) {
            var attributes, children, _ref;
            attributes = _arg.attributes, children = _arg.children;
            children || (children = []);
            return this('div', {
              "class": ['post']
            }, [attributes != null ? (_ref = attributes.data) != null ? _ref.title : void 0 : void 0].concat(children));
          }
        }
      ]);
    });
  });
  describe("Strings are treated as nodes", function() {
    return it("should use the correct children", function() {
      var $, result, tree;
      $ = GOM();
      tree = {
        tag: "custom",
        children: ["<p>Some text</p>"]
      };
      result = $.transform(tree, function(node) {
        return $("IGNORE", null, node.children);
      });
      return expect(result).to.deep.equal({
        tag: "IGNORE",
        children: [
          {
            tag: "IGNORE"
          }
        ]
      });
    });
  });
  return describe("Transform parent in callback parans", function() {
    return it("should use the correct children", function() {
      var $, result, transforms, tree;
      $ = GOM();
      tree = $('section', {
        id: 'section-1'
      }, [
        $('article', {
          id: 'article-1'
        }, [$('h1', null, "title 1")]), $('article', {
          id: 'article-2'
        }, [$('h1', null, "title 2")])
      ]);
      transforms = function(node, parent) {
        var parentId;
        parentId = this.getAttribute(parent, 'id');
        if (parentId != null) {
          this.setAttribute(node, 'parent-id', parentId);
        }
        return node;
      };
      result = $.transform(tree, transforms);
      return expectHTML(result, "\n<section id=\"section-1\">\n  <article id=\"article-1\", parent-id=\"section-1\">\n    <h1 parent-id=\"article-1\">title 1</h1>\n  </article>\n  <article id=\"article-2\", parent-id=\"section-1\">\n    <h1 parent-id=\"article-2\">title 2</h1>\n  </article>\n</section>\n");
    });
  });
});
