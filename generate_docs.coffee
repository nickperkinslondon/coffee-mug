#
# Coffee-Mug
# generate_docs.coffee
# by Nick Perkins, 2012
#
# Use Coffeemug itself to generate HTML doc about Coffeemug,
#  including showing the tests as examples:
#
coffeemug = require './coffeemug'
test_data = require './test/test_data'

util      = require 'util'
http      = require 'http'
fs        = require 'fs'

say = console.log

generate_docs = (callback)->

  example_server_code = fs.readFileSync './example_server.coffee'
  example_server_code = example_server_code.toString()
  docs_template = ->

    show_coffee = (s)->
      @pre class:'coffeescript', s

    @html ->
      @comment "This HTML generated with Coffee-Mug"
      @head ->
        @style """
          body{
            max-width: 960px;
            font-family:Arial;
            margin:0 auto;
            padding:50px;
          }
          pre{
            font-family:Lucida Console,Monaco,Consolas,Menlo,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,monospace;
            padding:10px;
          }
          pre.coffeescript{
            background:wheat;
            font-weight:bold;
          }
          pre.args{
            background:lightblue;
          }
          pre.html{
            background:aquamarine;
          }
          """
      @body ->
        @table ->

          @tr ->
            @h1 'Coffee-Mug'
            @h2 'HTML Templating with CoffeeScript'

          @tr -> @td colspan:9, ->
            @call show_coffee, """
              @html ->
                @body ->
                  @h1 'Coffeemug'
              """
            @a href:'https://github.com/nickperkinslondon/coffee-mug', 'github'
            @br()
            @br()

            @p """
              Coffee-Mug is an alternative to conventional HTML templating in Javascript/Coffeescript.
              It is both powerful and dangerous ( for the same reason ): templates are written in Coffeescript,
              and are executed ( more-or-less ) directly. This gives the template writer
              unlimited power to do loops, conditionals, functions,...anything.
              """
            @p """
              Of course, with great power comes great responsibility.
              If you are looking for a "sandboxed" template engine...this is not it.
              """
            @p """
              Templates can be used in 2 ways:
              """
            @p """
              """
            @p """
              """
            @p """
              1) Template as a string: This is like conventional templating
              -- the template is stored as text, probably in a file.
              Coffeemug will compile the template using the Coffeescript compiler.
              The resulting function will be then be called to generate the HTML.
              """
            @p """
              2) Template as a function.  The template is actual code.
              The template function retains whatever closure it had when declared.
              In this mode, Coffeemug isn't really a "template engine" at all -- it's just a fast HTML generation library.
              """
            @p """
              For example, here is a simple server for Node.js, where the "template"
              is defined on-the-spot as an anonymous function:
              """

            code = @escape example_server_code

            @call show_coffee, code
            @p "The above code is in 'example_server.coffee', and you can run it"


            @p 'The following examples are the actual test suite for the package:'


          @tr -> @td colspan:9, -> @hr()
          for test in test_data.tests
            if typeof test.template is 'string'
              cs = test.template
            else
              #cs = '[function template]'
              # actually, just skip it
              continue

            #
            # We are actually going to run all of the tests.
            # This is a lot of "logic" running inside a "template",
            # ...you might wish to separate form and function more than this...
            # ( or not )
            #
            if not test.args
              test.args = []
            apply_args = test.args[0..]
            apply_args.push test.template

            # run the template function, get the result:
            try
              actual_html = coffeemug.render.apply(coffeemug,apply_args)
            catch e
              actual_html = String(e)

            @tr ->
              @td colspan:9, ->
                @h3 test.description + ':'

            @tr ->
              @td 'Coffeemug Template:'
              @td -> @pre class:'coffeescript', (@escape cs)

            if test.args.length >0
              @tr ->
                @td 'Arguments:'
                @td ->
                  @pre class:'args', (util.inspect test.args)
            @tr ->
              @td 'Rendered HTML:'
              @td ->
                @pre class:'html', (@escape test.expected_html)
            @tr ->
              @td ->
                @p ->
                    if actual_html == test.expected_html
                      # @span style:'color:green', "PASS"
                    else
                      @pre -> @span style:'color:red;', ("FAIL! expected: \n"+escape(actual_html))
            @tr -> @td colspan:9, -> @hr()

      @p ->
        @text "This page itself is generated with Coffee-Mug, by "
        @a href:"https://github.com/nickperkinslondon/coffee-mug/blob/master/generate_docs.coffee", ->
          @text "generate_docs.coffee"

  html = coffeemug.render docs_template

  fs = require 'fs'
  fs.writeFileSync 'coffeemug_docs.html', html
  say 'wrote coffeemug_docs.html'

  callback()


# be a module?...or just run?
if exports
  exports.generate_docs = generate_docs
else
  generate_docs()

