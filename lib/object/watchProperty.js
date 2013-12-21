/**
 * bindable.bind("a", fn);
 */

function watchSimple (bindable, property, fn) {
  var listener = bindable.on("change:" + property, fn);

  return {
    now: function () {
      fn(bindable.get(property));
    },
    dispose: function () {
      listener.dispose();
    }
  }
}

/**
 * bindable.bind("a.b.c.d.e", fn);
 */

function watchChain (bindable, hasComputed, chain, fn) {

  var listeners = [], values, self;

  function onChange () {
    dispose();
    listeners = [];
    values = undefined;
    bind(bindable, chain);
    self.now();
  }

  function bind (target, chain) {

    var subChain, subValue, currentProperty, j, computed;

    for (var i = 0, n = chain.length; i < n; i++) {

      subChain        = chain.slice(0, i + 1);
      currentProperty = chain[i];

      if (hasComputed) {

          if (currentProperty.charCodeAt(0) === 64) {
            subChain[i] = subChain[i].substr(1);
            computed = true;
          }

          subValue        = target.get(subChain);

          if (computed) {
            if (subValue) {
              var context = target.get(subChain.slice(0, subChain.length - 1));

              if (subValue.compute) {
                for (var i = subValue.compute.length; i--;) {
                  bind(target, subValue.compute[i]);
                }
              }

              var eachChain = chain.slice(i + 1);

              subValue.call(context, function (item) {

                if (!eachChain.length) {
                  if (!values) values = [];
                  values.push(item);
                }

                // must be a bindable object to continue
                if (item && item.__isBindable) {
                  bind(item, eachChain);
                }
              });
            }
          }
      } else {
        subValue        = target.get(subChain);

        // pass the watch onto the bindable object, but also listen 
        // on the current target for any
        if (subValue && subValue.__isBindable) {
          bind(subValue, chain.slice(i + 1));
        }
      }

      listeners.push(target.on("change:" + subChain.join("."), onChange));
    }

    if (!values) values = subValue;
  }

  function dispose () {
    if (!listeners) return;
    for (var i = listeners.length; i--;) {
      listeners[i].dispose();
    }
    listeners = undefined;
  }

  bind(bindable, chain);

  return self = {
    now: function () {
      fn(values);
    },
    dispose: dispose
  }
}

/**
 * bindable.bind("@each.name", fn);
 */


/**
 */

module.exports = function (bindable, property, fn) {

  var chain        = property.split(".");

  // collection.bind("length")
  if (chain.length === 1) return watchSimple(bindable, property, fn);

  // person.bind("city.zip")
  return watchChain(bindable, ~property.indexOf("@"), chain, fn);
}