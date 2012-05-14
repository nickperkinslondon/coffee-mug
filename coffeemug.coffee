#
# coffeemug.coffee
#  an html template engine
#  inspired by CoffeeKup.coffee
#  by Nick Perkins, May 2012
#

indent = 0
leading_space = ()->
  Array(indent+1).join '  '

buffer = []
at_start = true # at beginning of a line
write = (s)->
  buffer.push s
  at_start = false
write_line = (s)->
  write leading_space() + s + '\n'
  at_start = true
start_line = (s)->
  if not at_start
    write '\n'
  write leading_space() + s
  at_start = false
end_line = (s)->
  write s + '\n'
  at_start = true

trim = (s)->s.replace /^\s+|\s+$/g, ''

make_tag = (tagname)->
  closetag = "</#{tagname}>"
  (args...)->
    # (content) or (attrs,content) ?
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
      for k, v of attrs
        switch typeof v
          when 'boolean'
            if v
              v = k # `true` is rendered as `selected="selected"`.
          when 'function'
            v = v #v.apply(this)?
          else
            v = v
        write " #{k}=\"#{v}\""
    write ">"

    if content
      write "#{content}"

    if content_fn
      write '\n'
      indent += 1
      content_fn.apply(this)
      indent -= 1

    write_line closetag



html = {} # this object will become "this" for template functions

tags = """
a abbr address article aside audio b bdi bdo
blockquote body button canvas caption cite
code colgroup datalist dd del details dfn
div dl dt em fieldset figcaption figure footer
form h1 h2 h3 h4 h5 h6 head header hgroup
html i iframe ins kbd label legend li
map mark menu meter nav noscript object
ol optgroup option output p pre progress
q rp rt ruby s samp script section
select small span strong style sub
summary sup table tbody td textarea tfoot
th thead time title tr u ul video'
"""
for line in tags.split '\n'
  for tagname in line.split(' ')
    #console.log 'tag : '+tagname
    html[tagname] = make_tag tagname

self_closing = """
area base br col command embed hr img input
keygen link meta param source track wbr'
"""
make_self_closing = (tagname)->
  s = "<"+tagname+"/>"
  return ()-> write s + '\n'

for line in self_closing.split '\n'
  for tagname in line.split ' '
    html[tagname] = make_self_closing tagname

html.text = (s)->write s

html.script = (f)->
  if typeof f is 'function'
    js = trim f.toString()
    write_line "<script>("
    indent +=1
    for line in js.split '\n'
      write_line line
    indent -=1
    write_line ")()</script>\n"

html.style = (s)->
  if typeof s is 'string'
    # indent the whole muli-line text:
    write_line '<style>'
    indent +=1
    for line in s.split '\n'
      write_line line
    indent -=1
    write_line '</style>'

html.doctype = (x)->
  write_line "<!DOCTYPE #{x}>"

render = (data,template) ->
  if typeof template != 'function'
    throw "template is not a function"

  buffer = []
  template.call(html, data)
  s = buffer.join ''
  return s

exports.render = render
