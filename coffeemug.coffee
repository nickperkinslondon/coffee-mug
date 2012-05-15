buffer = []
indent = 0
at_start = true # at beginning of a line

leading_space = ()->
  Array(indent+1).join '  '

write = (s)->
  buffer.push s
  at_start = false
write_line = (s)->
  if not at_start
    write '\n'
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

tags = """ a abbr address article aside audio b bdi bdo
blockquote body button canvas caption cite code colgroup
datalist dd del details dfn div dl dt em fieldset figcaption
figure footer form h1 h2 h3 h4 h5 h6 head header hgroup html
i iframe ins kbd label legend li map mark menu meter nav
noscript object ol optgroup option output p pre progress q rp
rt ruby s samp script section select small span strong style
sub summary sup table tbody td textarea tfoot th thead time
title tr u ul video """

self_closing_tags = """ area base br col command embed hr
img inputkeygen link meta param source track wbr """

write_attrs = (attrs)->
  for k, v of attrs
    switch typeof v
      when 'boolean'
        if v
          v = k # `true` is rendered as `selected="selected"`.
      when 'function'
        v = v.apply(this) #?
      else
        v = v
    write " #{k}=\"#{v}\""


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
      write_attrs attrs
    write ">"

    if content
      write " #{content} "
      end_line closetag

    if content_fn
      indent += 1
      content_fn.apply(this)
      indent -= 1
      write_line closetag

make_self_closing_tag = (tagname)->
  return (attrs)->
    start_line "<"+tagname
    if typeof attrs is 'object'
      write_attrs attrs
    end_line "/>"

html = {} # this object will become "this" for template functions

for line in tags.split '\n'
  for tagname in line.split(' ')
    html[tagname] = make_tag tagname

for line in self_closing_tags.split '\n'
  for tagname in line.split ' '
    html[tagname] = make_self_closing_tag tagname

html.text = (s)->write s

html.script = (f)->
  if typeof f is 'function'
    js = trim f.toString()
    start_line "<script>("
    for line in js.split '\n'
      end_line line
    write_line ")()</script>"

html.style = (s)->
  if typeof s is 'string'
    write_line '<style>'
    indent +=1
    for line in s.split '\n'
      write_line line
    indent -=1
    write_line '</style>'

html.doctype = (x)->
  write_line "<!DOCTYPE #{x}>"

exports.render = (data,template) ->
  buffer = []
  template.call(html, data)
  buffer.join ''
