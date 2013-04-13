
coffeemug = require '../coffeemug'
coffeemug_lite = require '../coffeemug_lite'
coffeescript = require 'coffee-script'

expect = require 'expect.js'

test_data = require './test_data'
expect(test_data.tests).to.be.an('array')

say = console.log
dir = console.dir



test_module = (cm)->

  for test in test_data.tests


    # sanity checks:
    # syntax of "test_data" might be wrong but valid
    # e.g. using "=" instead of ":" still compiles,
    #  but destroys stucture of the test data!
    expect(test).to.have.keys('description','template','expected_html')
    expect(test.description).to.be.a('string')
    expect(test.expected_html).to.be.a('string')


    # is the TEMPLATE a function, or a string?
    if typeof template is not 'function'
      if typeof template is 'string'

        if cm == coffeemug
          say 'using a string template for ' + test.description
        else
          template = coffeescript.compile(template)
          say 'converting template to function for CM-Lite'


    # optionally:
    if test.args is undefined
      test.args = []

    expect(test.args).to.be.an('array') # for tests only..."render" itself is more flexible


    # need a closure for "test" because....wait, do we need this?
    do (test)->

      result_html = ''

      do_render = ->
        args = test.args.slice(0) or []
        expect(args).to.be.an('array')
        args.push test.template
        result_html = coffeemug.render.apply(coffeemug,args)

      #
      # This works 2 ways:
      # 1) stand-alone script ( runs tests itself, reports errors )
      #  or
      # 2) a set of Mocha tests ( "describe"/"describe"/"it" )
      #    which run when you do "cake test"
      #
      if typeof describe is 'function'
        #
        # we are being run by Mocha test!
        #
        describe 'Coffeemug Test/',->
          describe test.description,->
            it '(works)',->
                # must do the rendering "inside" this test instead of before
                # in case an exception occurs during render, then Mocha will catch it properly
                do_render()
                if result_html != test.expected_html
                  # Mocha will produce a nice colorful "diff"
                  #  if we provide "expected" and "actual" html:
                  e = new Error
                  e.expected = test.expected_html
                  e.actual   = result_html
                  throw e
      else
        #
        # not a mocha test, we are running our own tests:
        #
        do_render()
        if result_html == test.expected_html
          say 'PASS: '+test.description
        else
          say ''
          say 'FAIL: '+test.description
          say 'exptected:'
          say test.expected_html
          say 'actual:'
          say result_html
          say ''
          #process.exit(1)


say 'test coffeemug'
test_module coffeemug

say 'test Coffee-Mug LITE'
test_module coffeemug_lite
