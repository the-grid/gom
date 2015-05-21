var $, GOM, assert, chai, expect, expectHTML, minify, toHTML;

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

$ = GOM();

describe("Helpers", function() {
  describe('isNode()', function() {
    it("with explicit node", function() {
      return chai.assert($.isNode($('div')));
    });
    it("with implicit node", function() {
      chai.assert($.isNode({}));
      return chai.assert($.isNode({
        attributes: {},
        children: {}
      }));
    });
    it("with string", function() {
      return chai.assert(!$.isNode("hello"));
    });
    it("with array", function() {
      return chai.assert(!$.isNode([]));
    });
    return it("with function", function() {
      var x;
      x = function() {};
      return chai.assert(!$.isNode(x));
    });
  });
  it('append()', function() {
    var node;
    node = $('div', {
      id: 'mommy',
      "class": ['parent thing']
    });
    $.append(node, $('div', {
      id: 'baby1',
      "class": ['child thing']
    }));
    $.append(node, $('div', {
      id: 'baby2',
      "class": ['child thing']
    }));
    return expectHTML(node, "<div id=\"mommy\" class=\"parent thing\">\n  <div id=\"baby1\" class=\"child thing\"></div>\n  <div id=\"baby2\" class=\"child thing\"></div>\n</div>");
  });
  it('prepend()', function() {
    var node;
    node = $('div', {
      id: 'mommy',
      "class": ['parent thing']
    });
    $.prepend(node, $('div', {
      id: 'baby1',
      "class": ['child thing']
    }));
    $.prepend(node, $('div', {
      id: 'baby2',
      "class": ['child thing']
    }));
    return expectHTML(node, "<div id=\"mommy\" class=\"parent thing\">\n  <div id=\"baby2\" class=\"child thing\"></div>\n  <div id=\"baby1\" class=\"child thing\"></div>\n</div>");
  });
  it('addClass()', function() {
    var node;
    node = $('div');
    $.addClass(node, 'foo');
    $.addClass(node, 'bar');
    $.addClass(node, ['boom', 'bang', 'foo', 'bar']);
    $.addClass(node, ['boom', 'bang', 'foo', 'bar']);
    return expectHTML(node, "<div class=\"foo bar boom bang\"></div>");
  });
  it('removeClass()', function() {
    var node;
    node = $('div');
    $.addClass(node, 'foo');
    $.addClass(node, 'bar');
    $.addClass(node, ['boom', 'bang', 'foo', 'bar']);
    $.removeClass(node, 'bar');
    $.removeClass(node, ['bang', 'foo', 'bar']);
    return expectHTML(node, "<div class=\"boom\"></div>");
  });
  it('hasClass()', function() {
    var node;
    node = $('div');
    chai.expect($.hasClass(node, 'foo')).to.be["false"];
    $.addClass(node, 'foo');
    chai.expect($.hasClass(node, 'foo')).to.be["true"];
    $.addClass(node, 'bar');
    chai.expect($.hasClass(node, ['foo', 'bar'])).to.be["true"];
    return chai.expect($.hasClass(node, ['foo', 'bang', 'bar'])).to.be["false"];
  });
  it('mergeAttributes() without exclusion', function() {
    var attrs, attrs1, mergedAttrs;
    attrs = {
      "class": ['hello']
    };
    attrs1 = {
      "class": ['world'],
      index: 'super',
      data: {
        block: {
          title: 'sometitle'
        }
      }
    };
    mergedAttrs = $.mergeAttributes(attrs, attrs1);
    return expect(mergedAttrs).to.deep.equal({
      "class": ['hello', 'world'],
      index: 'super',
      data: {
        block: {
          title: 'sometitle'
        }
      }
    });
  });
  it('mergeAttributes() with exclusion', function() {
    var attrs, attrs1, mergedAttrs;
    attrs = {
      "class": ['hello']
    };
    attrs1 = {
      "class": ['world'],
      index: 'super',
      data: {
        block: {
          title: 'sometitle'
        }
      }
    };
    mergedAttrs = $.mergeAttributes(attrs, attrs1, ['data']);
    return expect(mergedAttrs).to.deep.equal({
      "class": ['hello', 'world'],
      index: 'super'
    });
  });
  it('merge with concat string', function() {
    var attrs, attrs1, mergedAttrs;
    attrs = {
      str: 'first'
    };
    attrs1 = {
      str: 'second'
    };
    mergedAttrs = $.mergeAttributes(attrs, attrs1, [], true);
    return expect(mergedAttrs).to.deep.equal({
      str: 'first second'
    });
  });
  it('merge without concat string', function() {
    var attrs, attrs1, mergedAttrs;
    attrs = {
      str: 'first'
    };
    attrs1 = {
      str: 'second'
    };
    mergedAttrs = $.mergeAttributes(attrs, attrs1, [], false);
    return expect(mergedAttrs).to.deep.equal({
      str: 'first'
    });
  });
  return describe('get & set Attribute', function() {
    var passThroughTest, test;
    test = function(name, node, passThrough) {
      if (passThrough == null) {
        passThrough = false;
      }
      return it(name, function() {
        $.setAttribute(node, 'foo', 'bar');
        chai.expect($.getAttribute(node, 'foo')).to.eql('bar');
        $.setAttribute(node, 'foo', 'bang');
        chai.expect($.getAttribute(node, 'foo')).to.eql('bang');
        $.setAttribute(node, 'hello', 'world');
        return expectHTML(node, "<div foo=\"bang\" hello=\"world\"></div>");
      });
    };
    passThroughTest = function(name, node, result) {
      return it(name, function() {
        $.setAttribute(node, 'foo', 'bar');
        chai.expect($.getAttribute(node, 'foo')).to.not.eql('bar');
        $.setAttribute(node, 'foo', 'bang');
        chai.expect($.getAttribute(node, 'foo')).to.not.eql('bar');
        $.setAttribute(node, 'hello', 'world');
        return expectHTML(node, result);
      });
    };
    test("with an explicit node", $('div'));
    test("with an implicit node", {
      tag: 'div'
    });
    passThroughTest("with a string", "hello", "hello");
    return passThroughTest("with a function", function() {
      return "hello";
    }, "hello");
  });
});
