/*
 * This file can be used for general library features of gom.
 *
 * The library features can be made available as CommonJS modules that the
 * components in this project utilize.
 */
if (typeof process !== 'undefined' && process.execPath && process.execPath.indexOf('node') !== -1) {
  require('coffee-script/register');
}

module.exports = require('./lib/DOM');
