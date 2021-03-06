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
* A [FrameworkResource] which represents the initial visual representation of
* a [Control].
*/
class ControlTemplate extends FrameworkResource
{
  FrameworkProperty controlTypeProperty;
  FrameworkProperty templateProperty;
  
  BuckshotObject makeMe() => new ControlTemplate();
  
  ControlTemplate(){
    _initializeControlTemplateProperties();
    
    //redirect the resource finder to the template property
    //otherwise the ControlTemplate itself would be retrieved as the resource
    //this._stateBag[FrameworkResource.RESOURCE_PROPERTY] = templateProperty;
    this._stateBag[FrameworkObject.CONTAINER_CONTEXT] = templateProperty;
  }
  
  void _initializeControlTemplateProperties(){
    controlTypeProperty = new FrameworkProperty(this, "controlType", (_){}, "");
    
    templateProperty = new FrameworkProperty(this, "template", (_){});
    
    //key is not needed, so just shadow copy whatever the controlType is.
    new Binding(this.controlTypeProperty, this.keyProperty);
  }
  
  String get controlType() => getValue(controlTypeProperty);
  set controlType(String value) => setValue(controlTypeProperty, value);
  
  FrameworkElement get template() => getValue(templateProperty);
  set template(FrameworkElement value) => setValue(templateProperty, value);
  
  String get type() => "ControlTemplate";
}
