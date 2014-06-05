var CalmSoul;

CalmSoul = (function() {
  function CalmSoul() {}

  CalmSoul.prototype._log = true;

  CalmSoul.prototype._debug = false;

  CalmSoul.prototype._info = true;

  CalmSoul.prototype.set = function() {
    var args, key, property, value, _results;
    args = {};
    if (typeof arguments[0] === 'object') {
      args = Array.prototype.slice.call(arguments).reduce(function(x, y) {
        return x.concat(y);
      });
    } else {
      args[arguments[0]] = arguments[1];
    }
    _results = [];
    for (key in args) {
      value = args[key];
      property = "_" + key;
      if (this[property] != null) {
        _results.push(this[property] = value);
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  CalmSoul.prototype.get = function(prop) {
    return this["_" + prop];
  };

  CalmSoul.prototype.log = function() {
    if (this._log) {
      return console.log.apply(console, arguments);
    }
  };

  CalmSoul.prototype.debug = function() {
    if (this._debug) {
      return console.log.apply(console, arguments);
    }
  };

  CalmSoul.prototype.info = function() {
    if (this._info) {
      return console.log.apply(console, arguments);
    }
  };

  return CalmSoul;

})();

var calmsoul = new CalmSoul();