//   Copyright (c) 2012, John Evans & LUCA Studios LLC
//
//   http://www.lucastudios.com/contact
//   John: https://plus.google.com/u/0/115427174005651655317/about
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

/**
* Represents a binding between two [FrameworkProperty] properties.
*
* ## Usage:
*
* ### Registering a Binding
* {var reference} = new Binding(...);
*
* ### Unregistering a Binding
* bindingReference.unregister();
*
*/
interface Binding default _BindingImplementation{

  /**
  * Instantiates a binding between [fromProperty] and [toProperty],
  *  with an optional [bindingMode] and [converter].
  */
  Binding(FrameworkProperty fromProperty,
    FrameworkProperty toProperty,
    [BindingMode bindingMode, IValueConverter converter]);

  /**
  * Instantiates a binding between [fromProperty] and [toProperty],
  * with an optional [bindingMode] and [converter].
  *
  * This constructor fails silently if the binding isn't established.
  */
  Binding.loose(FrameworkProperty fromProperty, FrameworkProperty toProperty,
    [BindingMode bindingMode, IValueConverter converter]);

  /**
  * Boolean value representing if the binding is set or not.
  *   **This value is set by the framework**.
  */
  bool bindingSet;

  /**
  * Unregisters the binding between two [FrameworkProperty] properties.
  */
  void unregister();

}


class _BindingImplementation extends BuckshotObject implements Binding
{
  BindingMode bindingMode;
  _BindingImplementation _twoWayPartner;
  final IValueConverter converter;
  final FrameworkProperty _fromProperty, _toProperty;

  bool bindingSet = false;

  BuckshotObject makeMe() => null;

  _BindingImplementation(
    this._fromProperty,
    this._toProperty,
    [this.bindingMode = BindingMode.OneWay,
    this.converter = const _DefaultConverter()])
  {
    if (_fromProperty == null || _toProperty == null)
      throw const BuckshotException("Attempted to bind"
        " to/from null FrameworkProperty.");

    //NOTE: circular bindings of same property are not checked
    // Circular bindings are not generally harmful because the
    // property system doesn't fire when values are equivalent
    // There is a case where it may be harmful, when value converters
    // are used to transform the values through the chain...
    if (_fromProperty === _toProperty)
      throw const BuckshotException("Attempted to bind"
        " same property together.");

    _registerBinding();
  }

  _BindingImplementation.loose(
    this._fromProperty,
    this._toProperty,
    [this.bindingMode = BindingMode.OneWay,
    this.converter = const _DefaultConverter()])
  {
    if (_fromProperty == null || _toProperty == null) return;

    //NOTE: circular bindings of same property are not checked
    // Circular bindings are not generally harmful because the property
    // system doesn't fire when values are equivalent
    // There is a case where it may be harmful, when value converters are
    // used to transform the values through the chain...
    if (_fromProperty === _toProperty)
      throw const BuckshotException("Attempted to bind"
        " same property together.");

    _registerBinding();
  }


  _registerBinding()
  {
    bindingSet = true;

    if (bindingMode == BindingMode.TwoWay){
      _fromProperty.sourceObject._bindings.add(this);

      //set the other binding, temporarily as a oneway
      //so that it doesn't feedback loop on this function
      _BindingImplementation other =
          new _BindingImplementation.loose(
                  _toProperty,
                  _fromProperty,
                  BindingMode.OneWay);
      this._twoWayPartner = other;
      other._twoWayPartner = this;

      //now set it to the proper binding type
      _toProperty
        .sourceObject
        ._bindings
        .last()
        .dynamic
        .bindingMode = BindingMode.TwoWay;

    }else{
      _fromProperty.sourceObject._bindings.add(this);

      //fire the new binding for one-way/one-time bindings?  make optional?
      _BindingImplementation._executeBindingsFor(_fromProperty);
    }
  }

  void unregister()
  {
    if (!bindingSet) return;
    bindingSet = false;
    int i = _fromProperty.sourceObject._bindings.indexOf(this, 0);

    if (i == -1) throw const BuckshotException("Binding not found"
      " in binding registry when attempting to unregister.");

    _fromProperty.sourceObject._bindings.removeRange(i, 1);

    // remove the peer binding if two-way
    if (bindingMode != BindingMode.TwoWay) return;

    _twoWayPartner.bindingSet = false;

    int pi = _twoWayPartner
                ._fromProperty
                .sourceObject
                ._bindings
                .indexOf(_twoWayPartner, 0);

    if (pi == -1) throw const BuckshotException("Two-Way partner binding"
      " not found in binding registry when attempting to unregister.");

    _twoWayPartner._fromProperty.sourceObject._bindings.removeRange(pi, 1);
  }

  static void _executeBindingsFor(FrameworkProperty property)
  {
    for (final binding in property.sourceObject._bindings){

      setValue(binding.dynamic._toProperty,
        binding.dynamic.converter.convert(getValue(binding.dynamic._fromProperty)));

      if (binding.dynamic.bindingMode == BindingMode.OneTime)
        binding.unregister();
    }
  }

  String get type() => "Binding";

}


class _DefaultConverter implements IValueConverter{
  const _DefaultConverter();

  Dynamic convert(Dynamic value, [Dynamic parameter]) => value;
}
