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

describe("GOM", function() {
  return describe("basics", function() {
    var $;
    $ = GOM();
    toHTML('<div>', $('div'), "<div></div>");
    toHTML('defaults', $(null, null, 'hello world'), "<div>hello world</div>");
    toHTML('<div>hello world</div>', $('div', {}, ['hello world']), "<div>hello world</div>");
    toHTML('<div class="hello" data-foo="bar">', $('div', {
      "class": ['hello'],
      'data-foo': 'bar'
    }), "<div class=\"hello\" data-foo=\"bar\"></div>");
    toHTML('undefined & null attribute', $('div', {
      "class": void 0,
      'data-foo': null,
      exists: 'yes'
    }), "<div exists=\"yes\"></div>");
    it('child by attributes.children', function() {
      var child, node;
      child = $('div', {
        id: 'baby',
        "class": ['child thing']
      });
      node = $('div', {
        id: 'mommy',
        "class": ['parent thing'],
        children: [child]
      });
      return expectHTML(node, "<div id=\"mommy\" class=\"parent thing\">\n  <div id=\"baby\" class=\"child thing\"></div>\n</div>");
    });
    it('3 level child by children param', function() {
      var node;
      node = $("section", {
        id: 'grand'
      }, [
        $("article", {
          id: 'mommy',
          "class": ['parent thing']
        }, [
          $("span", {
            id: 'baby',
            "class": ['child thing']
          })
        ])
      ]);
      return expectHTML(node, "<section id=\"grand\">\n  <article id=\"mommy\" class=\"parent thing\">\n    <span id=\"baby\" class=\"child thing\"></span>\n  </article>\n</section>");
    });
    it('mixed children', function() {
      var node;
      node = $("a", {
        href: 'google.com'
      }, ["this is ", $("span", {}, "awesome"), "... for reals!"]);
      return expectHTML(node, "<a href=\"google.com\">this is <span>awesome</span>... for reals!</a>");
    });
    it('render node array', function() {
      var nodes;
      nodes = [$("head"), $("body")];
      return expectHTML(nodes, "<head></head>\n<body></body>");
    });
    it('ignore nested children arrays', function() {
      var build;
      build = function() {
        return $("section", {}, [
          [
            [
              [
                $("div", {
                  id: 1
                })
              ]
            ]
          ], [
            [
              $("div", {
                id: 2
              })
            ]
          ], [
            $("div", {
              id: 3
            })
          ], $("div", {
            id: 4
          })
        ]);
      };
      return expectHTML(build(), "<section><div id=\"1\"></div><div id=\"2\"></div><div id=\"3\"></div><div id=\"4\"></div></section>");
    });
    it('ignore falsey children', function() {
      var build;
      build = function() {
        return $("section", {}, [[null], [[null]], $("div"), null, [[void 0]]]);
      };
      return expectHTML(build(), "<section>\n  <div></div>\n</section>");
    });
    it('empty tags', function() {
      var build;
      build = function() {
        return [
          $("img", {
            "class": ['img']
          }), $("hr", {
            "class": ['hr']
          }), $("input", {
            "class": ['input']
          })
        ];
      };
      return expectHTML(build(), "<img class=\"img\"/>\n<hr class=\"hr\"/>\n<input class=\"input\"/>");
    });
    it('functional children', function() {
      var build;
      build = function() {
        return [
          function() {
            return $("img", {
              "class": ['img']
            });
          }, [
            function() {
              return $("hr", {
                "class": ['hr']
              });
            }
          ], function() {
            var html, str, _i, _len, _ref;
            html = "";
            _ref = ["hello", "functional", "offspring"];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              str = _ref[_i];
              html += " " + str;
            }
            return html.trim();
          }
        ];
      };
      return expectHTML(build(), "<img class=\"img\"/>\n<hr class=\"hr\"/>hello functional offspring");
    });
    it('object children', function() {
      var build;
      build = function() {
        return [
          {
            tag: 'div',
            attributes: {
              "class": ['box'],
              style: {
                color: 'red'
              },
              'data-special': 'sauce'
            },
            children: [
              {
                tag: 'img',
                attributes: {
                  "class": ['cover']
                }
              }
            ]
          }, function() {
            return {
              tag: 'section'
            };
          }
        ];
      };
      return expectHTML(build(), "<div class=\"box\" style=\"color:red;\" data-special=\"sauce\">\n  <img class=\"cover\"/>\n</div>\n<section></section>");
    });
    it('style attribute', function() {
      var build;
      build = function() {
        return [
          $("div", {
            id: 'styled',
            style: {
              'background-color': "blue",
              'color': "hsl(0,0%,0%)",
              "line-height": 1.5
            }
          })
        ];
      };
      return expectHTML(build(), "<div id=\"styled\" style=\"background-color:blue; color:hsl(0,0%,0%); line-height:1.5;\"></div>");
    });
    return it('object & array attributes are ignored', function() {
      var build;
      build = function() {
        return [
          $("div", {
            "class": ['obj-attrs'],
            $class: ['ignore', 'me'],
            gss: {
              align: 'right'
            },
            item: {
              id: 100
            }
          })
        ];
      };
      return expectHTML(build(), "<div class=\"obj-attrs\"></div>");
    });
  });
});
