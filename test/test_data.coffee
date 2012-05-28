#
# Coffeemug test data is used for 2 things:
# 1) run tests
# 2) generate documentation
#

tests = exports.tests = []

#-----------------------------------------------------------------------------
tests.push

  description : 'Templates are pure Coffeescript, so indentation is significant'
  debug:false

  template : '''
    @html ->
      @body ->
        @h1 'Coffeemug'

  '''

  expected_html : '''
    <html>
      <body>
        <h1> Coffeemug </h1>
      </body>
    </html>

    '''

#-----------------------------------------------------------------------------
tests.push

  description : '...but you can do stuff on one line'
  debug:false

  template : '''
    @html -> @body -> @h1 'Coffeemug'

  '''

  expected_html : '''
    <html>
      <body>
        <h1> Coffeemug </h1>
      </body>
    </html>

    '''


#-----------------------------------------------------------------------------
tests.push

  description : 'Tag attributes are easy'

  template : '''
    @html ->
      @body ->
        @div
          id:'the-div'
          class:'regular'
          style:'border:1px solid black'
    '''

  expected_html : '''
    <html>
      <body>
        <div id="the-div" class="regular" style="border:1px solid black"></div>
      </body>
    </html>

    '''


#-----------------------------------------------------------------------------
tests.push

  description : 'Tag attributes plus content'

  template : '''
    @html ->
      @body ->
        @div
          id:'the-div'
          class:'regular'
          style:'border:1px solid black'
          ->
            @h1 'Coffeemug'
    '''

  expected_html : '''
    <html>
      <body>
        <div id="the-div" class="regular" style="border:1px solid black">
          <h1> Coffeemug </h1>
        </div>
      </body>
    </html>

    '''



#-----------------------------------------------------------------------------
tests.push

  description : 'Scripts are converted to Javascript'

  template : '''
    @html ->
      @head ->
        @script ->
          square = (x) -> x * x
          n = square 3
          alert "the number is: #{n}"
    '''

  expected_html : """
    <html>
      <head>
        <script>(function () {
                  var n, square;
                  square = function(x) {
                    return x * x;
                  };
                  n = square(3);
                  return alert("the number is: " + n);
                })();
        </script>
      </head>
    </html>

    """

#-----------------------------------------------------------------------------
tests.push

  description : 'Template can take an argument'
  debug:false
  template : """
    (title)->
      @html ->
        @head ->
        @body ->
          @h1 title

    """

  #rendered_html = coffeemug.render "CoffeeMug", template
  args : [ "Coffeemug" ]

  expected_html : """
    <html>
      <head>
      </head>
      <body>
        <h1> Coffeemug </h1>
      </body>
    </html>

    """


#--------------------------------------------------------------------------
tests.push
  description : 'Template with two arguments'

  template : """
    (title,subtitle)->
      @html ->
        @head ->
        @body ->
          @h1 title
          @h2 subtitle
    """

  args : ["CoffeeMug", "the anti-template"]

  expected_html : """
    <html>
      <head>
      </head>
      <body>
        <h1> CoffeeMug </h1>
        <h2> the anti-template </h2>
      </body>
    </html>

    """


#-----------------------------------------------------------------------------
tests.push
  description : 'Template with any number of (...) arguments'
  debug:false
  template : """

    (things...)->
      @html ->
        @body ->
          @ul ->
            for thing in things
              @li thing
    """

  args : ["one","two","three"]

  expected_html : """
    <html>
      <body>
        <ul>
          <li> one </li>
          <li> two </li>
          <li> three </li>
        </ul>
      </body>
    </html>

    """


#-----------------------------------------------------------------------------
tests.push
  description : 'Argument can be an object'

  template : """

    (data)->
      @html ->
        @body ->
          @h1 data.title
          @h2 data.subtitle
    """

  args : [
    title:'CoffeeMug'
    subtitle:'pure coffeescript html templating'
  ]

  #rendered_html = coffeemug.render data, template
  expected_html : """
    <html>
      <body>
        <h1> CoffeeMug </h1>
        <h2> pure coffeescript html templating </h2>
      </body>
    </html>

    """



#-----------------------------------------------------------------------------
tests.push

  description : 'Argument object could be helper functions'

  template : """
    (helpers)->
      @html ->
        @body ->
          @h1 helpers.capitalize 'coffeemug'
          @h2 helpers.format_money 0
    """

  args : [
    format_money:(n)->
      return '$'+n
    capitalize:(s)->
      return s.substring(0,1).toUpperCase() + s.substring(1,99)
  ]

  expected_html : """
    <html>
      <body>
        <h1> Coffeemug </h1>
        <h2> $0 </h2>
      </body>
    </html>

    """


#-----------------------------------------------------------------------------
tests.push
  description : 'Templates may define local functions and call them with args'

  template : """
    (name,address)->
      make_title=(s)->
        @h1 s
      make_subtitle=(s)->
        @h2 s
      @html ->
        @body ->
          @call make_title, name
          @call make_subtitle, address
    """

  args: ["Nick", "Canada"]

  expected_html : """
    <html>
      <body>
        <h1> Nick </h1>
        <h2> Canada </h2>
      </body>
    </html>

    """

#-----------------------------------------------------------------------------
#
# non-string templates are actual functions
#  they can do even more because they keep their original closure:
#
format_money = (n)->
    return '$'+n

capitalize = (s)->
    return s.substring(0,1).toUpperCase() + s.substring(1,99)

tests.push
  description : 'non-string function templates retain their closure'
  # NOTE: this would FAIL if the template were a string!

  template : ->
    @html ->
      @body ->
        @h1 capitalize 'coffeemug' # capitalize defined in closure
        @h2 format_money '0'       # format_money defined in closure

  expected_html : """
    <html>
      <body>
        <h1> Coffeemug </h1>
        <h2> $0 </h2>
      </body>
    </html>

    """


#-----------------------------------------------------------------------------
tests.push
  description:'comments'
  template : """
    @html ->
      @head ->
        @comment "This is a comment"

    """

  expected_html:"""
    <html>
      <head>
        <!-- This is a comment -->
      </head>
    </html>

    """

#-----------------------------------------------------------------------------
tests.push
  description    : 'nothing is nothing'
  template       : ""
  expected_html : ""

#-----------------------------------------------------------------------------
tests.push
  description    : 'empty fn is nothing'
  template       : ->
  expected_html : ""

#-----------------------------------------------------------------------------
tests.push
  description    : 'text'
  template       : """
    @text "abc"
    """
  expected_html : "abc"

#-----------------------------------------------------------------------------
tests.push
  description    : 'doctype'
  template       : """
    @doctype 'html'
    @html ->
      @body ->
    """

  expected_html : """
    <!DOCTYPE html>
    <html>
      <body>
      </body>
    </html>

  """

#-----------------------------------------------------------------------------
tests.push

  description    : 'escaping'
  template       : """
    @pre @escape "<h1>"

    """

  expected_html : """
    <pre>&lt;h1&gt;</pre>

    """

#-----------------------------------------------------------------------------
tests.push
  description    : 'invalid code'
  template       : """
    fds fds fds
  """
  expected_html : "ReferenceError: fds is not defined"
