var GOM, assert, chai, expect, expectHTML, minify, toHTML;

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

describe("hooks", function() {
  describe('basics', function() {
    var $;
    $ = GOM({
      "post": function(attributes, children) {
        var title;
        title = attributes.data.title;
        if (!title) {
          throw new Error('Missing post title');
        }
        return this('div', {
          "class": ['post']
        }, title);
      }
    });
    it('works', function() {
      var node;
      node = $('post', {
        data: {
          title: 'Tis a post!'
        }
      });
      return expectHTML(node, "<div class=\"post\">Tis a post!</div>");
    });
    return it('fails with missing data', function() {
      return expect(function() {
        return $('post', {
          data: {}
        });
      }).to["throw"](Error);
    });
  });
  describe('hooks with merges', function() {
    var $;
    $ = GOM({
      "cta": function(attributes, children) {
        if (attributes == null) {
          attributes = {};
        }
        attributes = this.mergeAttributes(attributes, {
          "class": ['cta']
        });
        return this('button', attributes, children);
      },
      "post": function(attributes, children) {
        var defaultPostattributes, postChildren, subtitle, title, _ref;
        if (attributes == null) {
          attributes = {};
        }
        _ref = attributes.data, title = _ref.title, subtitle = _ref.subtitle;
        defaultPostattributes = {
          "class": ['post'],
          style: {
            'color': 'red',
            opacity: 0
          },
          index: 'cover'
        };
        attributes = this.mergeAttributes(attributes, defaultPostattributes);
        postChildren = [this("h1", {}, title), this("h2", {}, subtitle)];
        children = this.mergeChildren(postChildren, children);
        return this('article', attributes, children);
      }
    });
    it('1 level', function() {
      var build;
      build = function() {
        return $('post', {
          "class": ['featured'],
          style: {
            opacity: 1
          },
          data: {
            title: 'Tis a post!',
            subtitle: 'indeed it is'
          }
        }, [
          $('cta', {
            "class": ['active']
          }, 'Buy Now')
        ]);
      };
      return expectHTML(build(), "<article class=\"featured post\" style=\"color:red; opacity:1;\" index=\"cover\">\n  <h1>Tis a post!</h1>\n  <h2>indeed it is</h2>\n  <button class=\"active cta\">Buy Now</button>\n</article>");
    });
    it('recursed', function() {
      var build;
      build = function() {
        return $('post', {
          "class": ['featured'],
          data: {
            title: 'Tis a post!',
            subtitle: 'indeed it is'
          }
        }, [
          $('cta', {
            "class": ['active']
          }, 'Buy Now'), $('post', {
            data: {
              title: 'Tis an inner post!',
              subtitle: 'indeed it is'
            },
            style: {
              "color": "blue"
            }
          })
        ]);
      };
      return expectHTML(build(), "<article class=\"featured post\" style=\"color:red; opacity:0;\" index=\"cover\">\n  <h1>Tis a post!</h1>\n  <h2>indeed it is</h2>\n  <button class=\"active cta\">Buy Now</button>\n  <article style=\"color:blue; opacity:0;\" class=\"post\" index=\"cover\">\n    <h1>Tis an inner post!</h1>\n    <h2>indeed it is</h2>\n  </article>\n</article>");
    });
    return it('with attributes duplication in merge', function() {
      var build;
      build = function() {
        return $('post', {
          "class": ['featured'],
          data: {
            title: 'Tis a post!',
            subtitle: 'indeed it is'
          },
          index: "cover"
        }, [
          $('cta', {
            "class": ['active']
          }, 'Buy Now'), $('post', {
            data: {
              title: 'Tis an inner post!',
              subtitle: 'indeed it is'
            },
            style: {
              "color": "blue"
            }
          })
        ]);
      };
      return expectHTML(build(), "<article class=\"featured post\" index=\"cover\" style=\"color:red; opacity:0;\">\n  <h1>Tis a post!</h1>\n  <h2>indeed it is</h2>\n  <button class=\"active cta\">Buy Now</button>\n  <article style=\"color:blue; opacity:0;\" class=\"post\" index=\"cover\">\n    <h1>Tis an inner post!</h1>\n    <h2>indeed it is</h2>\n  </article>\n</article>");
    });
  });
  return describe('hooks > includes & extends w/ blocks', function() {
    var $;
    $ = GOM({
      "layout": function(attributes, children, _arg) {
        var footer;
        if (children == null) {
          children = "";
        }
        footer = _arg.footer;
        return this("html", {}, [this("head"), this("body", {}, [children, this("footer", {}, [footer])])]);
      },
      "page-layout": function(attributes, children) {
        return this("layout", {}, [
          this("header", {
            "class": ['page-header']
          }), children
        ], {
          footer: [this("a", {}, "In da footah")]
        });
      }
    });
    return it("works", function() {
      var build;
      build = function() {
        return $("page-layout", {}, [$("article", {}, "page 1 article 1")]);
      };
      return expectHTML(build(), "<html>\n  <head>\n  </head>\n  <body>\n    <header class=\"page-header\"></header>\n    <article>page 1 article 1</article>\n    <footer><a>In da footah</a></footer>\n  </body>\n</html>");
    });
  });
});
