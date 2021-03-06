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
* Static helpers for working with the DOM.
*
*/
class Dom {
  static final prefixes = const ['','-webkit-','-moz-','-o-','-ms-'];
  
  /// Appends the given [String] as a class to the given [Element].
  static void appendClass(Element element, String classToAppend){
    String currentClasses = element.attributes["class"];
    currentClasses = currentClasses == null || currentClasses == "null" ? "" : currentClasses;
    element.attributes["class"] = currentClasses != "" ? '$currentClasses $classToAppend' : classToAppend;
  }

  /// Creates an [Element] from the given [String] html tag name.
  static Element createByTag(String tagName) => new Element.tag(tagName);

  static void appendBuckshotClass(Element element, String classToAppend) => 
      Dom.appendClass(element, 'buckshot_$classToAppend');

  /** Converts and element into a flexbox container. */
  static void makeFlexBox(FrameworkObject element){
    prefixes.forEach((String p){
      var pre = '${p}box'; //assigning here because some bug won't let me pass it directly in .setProperty
      element._component.style.display = pre;
      pre = '${p}flexbox';
      element._component.style.display = pre;
      pre = '${p}flex';
      element._component.style.display = pre;
    });

  }

  /** Returns a string representing a cross-browser CSS property assignment. */
  static String generateXPCSS(String declaration, String value){
    StringBuffer sb = new StringBuffer();

    prefixes.forEach((String p){
      sb.add('${p}${declaration}: ${value};');
    });

    return sb.toString();
  }

  /** Returns true if the given property is supported. */
  static bool checkCSS3Support(Element e, String property, String value){

    var result = getXPCSS(e, property);

    if (result != null) return true;

    setXPCSS(e, property, value);

    result = getXPCSS(e, property);

    if (result != null){
      removeXPCSS(e, property);
      return true;
    }

    return false;
  }

  /** Removes a given CSS property from an HTML element. Supports all common browser prefixes. */
  static void removeXPCSS(Element e, String property){
    for(final String p in prefixes){
      var pre = '${p}${property}'; //assigning here because some bug won't let me pass it directly in .setProperty
      e.style.removeProperty(pre);
    }
  }

  /** Returns true if able to set a a given CSS value/property. Supports all common browser prefixes.  */
  static bool attemptSetXPCSS(Element e, String property, String value){
    setXPCSS(e, property, value);
    return getXPCSS(e, property) != null;
  }

  /** Assigns a value to a property of an element that ensures cross-browser support. Supports all common browser prefixes.  */
  static void setXPCSS(Element e, String property, String value){
    prefixes.forEach((String p){
     var pre = '${p}${property}'; //assigning here because some bug won't let me pass it directly in .setProperty
     e.style.setProperty(pre, value, '1');
     });
  }

  /** Gets a value from a given property.   Supports all common browser prefixes. */
  static String getXPCSS(Element e, String property){

    for(final String p in prefixes){
      var pre = '${p}${property}'; //assigning here because some bug won't let me pass it directly in .setProperty
      String result = e.style.getPropertyValue(pre);

      if (result != null) return result;
    }

    return null;
  }

  static void setFlexBoxOrientation(FrameworkElement element, Orientation orientation){
    setXPCSS(element.rawElement, 'flex-direction', (orientation == Orientation.horizontal) ? 'row' : 'column');
  }

  /// For individual items within a flexbox, but only in the cross-axis.
  static void setHorizontalItemFlexAlignment(FrameworkElement element, HorizontalAlignment alignment){
    switch(alignment){
      case HorizontalAlignment.left:
        setXPCSS(element.rawElement, 'align-self', 'flex-start');
        break;
      case HorizontalAlignment.right:
        setXPCSS(element.rawElement, 'align-self', 'flex-end');
        break;
      case HorizontalAlignment.center:
        setXPCSS(element.rawElement, 'align-self', 'center');
        break;
      case HorizontalAlignment.stretch:
        setXPCSS(element.rawElement, 'align-self', 'stretch');
        break;
      }
  }

  /// For individual items within a flexbox, but only in the cross-axis.
  static void setVerticalItemFlexAlignment(FrameworkElement element, VerticalAlignment alignment){

    switch(alignment){
      case VerticalAlignment.top:
        setXPCSS(element.rawElement, 'align-self', 'flex-start');
        break;
      case VerticalAlignment.bottom:
        setXPCSS(element.rawElement, 'align-self', 'flex-end');
        break;
      case VerticalAlignment.center:
        setXPCSS(element.rawElement, 'align-self', 'center');
        break;
      case VerticalAlignment.stretch:
        setXPCSS(element.rawElement, 'align-self', 'stretch');
        break;
      }
  }

  static void setHorizontalFlexBoxAlignment(FrameworkObject element, HorizontalAlignment alignment){
    switch(alignment){
      case HorizontalAlignment.left:
        setXPCSS(element.rawElement, 'justify-content', 'flex-start');
        //element._component.style.flexPack = 'start';
        break;
      case HorizontalAlignment.right:
        setXPCSS(element.rawElement, 'justify-content', 'flex-end');
        //element._component.style.flexPack = 'end';
        break;
      case HorizontalAlignment.center:
        setXPCSS(element.rawElement, 'justify-content', 'center');
        //element._component.style.flexPack = 'center';
        break;
      case HorizontalAlignment.stretch:
        //TODO start?
        setXPCSS(element.rawElement, 'justify-content', 'stretch');
        //element._component.style.flexPack = 'start';
        break;
      }
  }

  static void setVerticalFlexBoxAlignment(FrameworkObject element, VerticalAlignment alignment){
    switch(alignment){
      case VerticalAlignment.top:
        setXPCSS(element.rawElement, 'align-items', 'flex-start');
        //element._component.style.flexAlign = 'start';
        break;
      case VerticalAlignment.bottom:
        setXPCSS(element.rawElement, 'align-items', 'flex-end');
        //element._component.style.flexAlign = 'end';
        break;
      case VerticalAlignment.center:
        setXPCSS(element.rawElement, 'align-items', 'center');
        //element._component.style.flexAlign = 'center';
        break;
      case VerticalAlignment.stretch:
        setXPCSS(element.rawElement, 'align-items', 'stretch');
        //element._component.style.flexAlign = 'stretch';
        break;
    }
  }
}
