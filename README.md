
# Coffeemug
# The Pure Coffeescript HTML Anti-Template

Coffeemug is not a template engine -- it is an html rendering library that allows you to write your HTML in pure coffeescript.  This approach is a bit different from the traditional "template engine" approach.

Your "templates" are not text files that are parsed, interpreted, or compiled, they are simply functions, written in Coffeescript, that return well-formatted HTML.  They may be included directly in server-side coffeescript, or loaded as modules using 'require'.

While this library could be used in Javascript, the whole point of it ( like the "coffeekup" project that came before ), is to take advantage of the syntax of coffeescript to allow you to write functions that look a bit like HAML, but have the full power of the coffeescript language.

This goes completely against the idea of separating the HTML markup from the programming, and is not "sandboxed" in any way -- the code in the "template" is free to do anything, so this is NOT for running any untrusted "templates".


### Features

* Pure Coffeescript -- no invented language
* Clean syntax
* Resulting HTML is perfectly formatted and indented


### Basic Example

```coffeescript
@html ->
  @body ->
    @h1 'Coffeemug'
```

Will render as:

```html
<html>
  <body>
    <h1> Coffeemug </h1>
  </body>
</html>
```

