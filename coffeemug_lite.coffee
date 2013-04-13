#
# coffeemug_lite.coffee
# by Nick Perkins, march 2013 -- to make this work on CouchDB, remove dependency on "coffee-script" module
# which means no compiling at all -- must be used by javascript functions
# ( which is ok -- that's how it works best )
#
#
# CommonJS Module System
#
server = false
if typeof exports != 'undefined'
  if typeof module != 'undefined' and module.exports
    server = true # on Node.js or similar

browser = not server

if server
  root = exports

if browser
  window.CoffeeMug = root = {}

if server
  expect = require 'expect.js'


say = (s)->
  log s # couchdb
  #console.log


html_tags = """ a abbr address article aside audio b bdi bdo blockquote
body button canvas caption cite code colgroup datalist dd del details
dfn div dl dt em fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6
head header hgroup html i iframe ins kbd label legend li map mark menu
meter nav noscript object ol optgroup option output p pre progress q rp
rt ruby s samp script section select small span strong style sub summary
sup table tbody td textarea tfoot th thead time title tr u ul video """

self_closing_tags = """ area base br col command embed hr img
input keygen link meta param source track wbr """

trim = (s)->s.replace /^\s+|\s+$/g, ''


#
# a "renderer" object does the rendering,
#  and keeps state ( like "buffer", and current indentation level )
#
renderer = ->
  #
  # constrcutor function:
  #  local vars will be private ( in closure )
  #  returned value ( API ) will be public
  #
  buffer = []     # list of strings to be concatenated
  indent = 0      # current indentation level
  at_start = true # are we currently at beginning of a line?

  debug = false   # debug mode: output stuff to console


  # function "write" and friends, help to write HTML to the buffer
  # and keep track of indentation etc...

  write = (s)->
    # no new line, no indentation, just write text
    buffer.push s
    at_start = false

  write_line = (s)->
    # write a new line, indented, and end the line
    if not at_start
      write '\n'
    write leading_space() + s + '\n'
    at_start = true

  start_line = (s)->
    # start a new indented line, but don't end the line yet
    if not at_start
      write '\n'
    write leading_space() + s
    at_start = false

  end_line = (s)->
      # continue the current line, write stuff, then end the line
      write s + '\n'
      at_start = true

  leading_space = ->
    # return a string of spaces for indentation
    Array(indent+1).join '  '

  write_attrs = (attrs)->
    # write out TAG Attributes ( within the opening tag )
    for k, v of attrs
      switch typeof v
        when 'boolean'
          if v
            v = k # true is rendered as 'selected="selected"' ( thanks coffeekup )
        else
          v = v
      write " #{k}=\"#{v}\""


  #
  # make_tag:
  #  Given a tagname, like 'h1', create and return a function
  #   that writes that tag to the buffer,  like "<h1>....</h1>"
  #  The created function also takes aguments to write the stuff in-between
  #
  make_tag = (tagname)->
    closetag = "</#{tagname}>"
    (args...)->
      #
      # tag args can be in any order, and are identified by type:
      #  a 'function' is indented multi-line content
      #  an 'object' is a set of tag attributes
      #  anything else is direct content for a one-liner
      #
      for a in args
        switch typeof a
          when 'object'
            attrs = a
          when 'function'
            content_fn = a
          else
            content = a

      start_line "<"+tagname
      if attrs
        write_attrs attrs
      write ">"

      if content
        if tagname == 'pre'
          write "#{content}" # don't add spaces
        else
          write " #{content} " # add space for readability
        end_line closetag
      else
        if content_fn
          indent += 1
          content_fn.apply(this)
          indent -= 1
          write_line closetag
        else
          end_line closetag


  #
  # a self-closing tag, like <img src='kitten.jpg' alt='Kitten'>
  #  has attributes, but no content,
  #  and no closing tag
  #
  make_self_closing_tag = (tagname)->
    return (attrs)->
      start_line "<"+tagname
      if typeof attrs is 'object'
        write_attrs attrs
      end_line "/>"


  #
  # The "template_this" object
  #  will become the "this" for template functions.
  #
  # This is how we magically pass all of the "@" functions
  #  into the template.
  #
  # We will attach a "tag function" for each tag to the "template_this" object.
  # The template can then call these using the coffeescript "@" operator:
  #
  # @html ->
  #   @body ->
  #     @h1 "Hello, World"
  #

  template_this = {}

  #
  # create attach all regular TAG functions:
  #
  for line in html_tags.split '\n'
    for tagname in line.split(' ')
      template_this[tagname] = make_tag tagname

  #
  # create and attach all Self-Closing TAG functions:
  #
  for line in self_closing_tags.split '\n'
    for tagname in line.split ' '
      template_this[tagname] = make_self_closing_tag tagname


  #
  # Special TAGs: text, script, style, doctype, etc.
  # Each of these works a bit differently from a standard tag,
  #  so they are defined separately:
  #
  template_this.text = (s)->
    # not a tag, just writes text directly to the buffer
    write s

  template_this.script = (f)->
    # content is a function ( written in coffeescript )
    # we convert it to javascript and put it in a <script> tag:
    if typeof f is 'function'
      #
      # argument is a function
      #  we "toString" it which creates "function(){...}",
      #   then add "()" to call the function immediately.
      #  so we end up with a closure,
      #   and the script cannot create global vars
      #
      js = trim f.toString()
      start_line "<script>("
      lines = js.split '\n'
      end_line lines[0]
      indent += 2
      for line in lines[1..]
        start_line line
      indent -= 2
      end_line ")();"
      write_line "</script>"

    if typeof f is 'object'
      start_line '<script'
      write_attrs f
      end_line '></script>'

  template_this.style = (s)->
    # style takes a mult-line string ( of CSS )
    # we make sure to indent the whole block of text:
    if typeof s is 'string'
      write_line '<style>'
      indent +=1
      for line in s.split '\n'
        write_line line
      indent -=1
      write_line '</style>'

  template_this.doctype = (x)->
    write_line "<!DOCTYPE #{x}>"

  template_this.call = (fn,args...)->
    #
    # Templates can "call" other templates
    # We have to "apply" the function to our "template_this"
    #  so that it writes to our buffer, and uses our indentation level, etc
    #
    if typeof fn is 'function'
      fn.apply(template_this,args)
    else
      throw new Error 'call takes a function as first arg'

  template_this.comment = (s)->
    write_line "<!-- "+s+" -->"

  template_this.escape = (text)->
    text.replace(/&/g,'&amp;')
    .replace(/</g,'&lt;')
    .replace(/>/g,'&gt;')
    .replace(/"/g,'&quot;')
    .replace(/'/g,'&#039;')



  original_button_function = template_this.button
  template_this.button = (text,atrs, fn)->
    if not fn and typeof atrs is 'function' then fn = atrs
    if fn and typeof fn is 'function'
      code = ''+fn      
      code = code.replace(/\n/g,'')
      code = code.replace(/\r/g,'')
      code = code.replace(/\t/g,' ')
      code = code.replace(/"/g,'\"')
      start_line '<button'
      if atrs
        write_attrs atrs
      end_line ' onclick="('+code+')()"> '+text+' </button>'
    else
      original_button_function text,atrs



  #
  # OK, all that was internal...now here's the public API:
  #
  API = {}

  API.set_debug = (b)->
    debug = b

  API.render = (args...,template) ->
    #
    # any number of args
    #  last arg is the template ( function or string )
    #  other args are passed to the template function
    #
    if typeof template is 'function'
      # ok, good
    else
      throw new Error 'template must be a function in CM-Lite!'

    if server
      expect(args).to.be.an('array') # might be empty
      expect(template).to.be.a('function') # was compiled if string


    #
    # Rendering the template is imply calling the template function,
    #  while setting the "this" object to the "template_this" object.
    #
    # The buffer is already in the closure
    #  of all of the "template_this" functions, so
    #  the same buffer is used for the entire rendering.
    #
    buffer = []
    template.apply(template_this,args)
    renedered_html = buffer.join ''
    return renedered_html

  return API



root.render = (args...)->
    r = renderer()
    try
      html = r.render.apply(r,args)
    catch e
      html = e.toString()
    return html

