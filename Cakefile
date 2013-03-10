
# Coffee-Mug
# Cakefile

child_process = require 'child_process'
say = console.log

build = (callback)->
  child_process.exec 'coffee -c *.coffee', (err,stdout,stderr)->
    if err
      say stderr
    else
      say 'compiled coffeemug'
      child_process.exec 'coffee -c test/*.coffee', (err,stdout,stderr)->
        if err
          say stderr
        else
          console.log 'compiled coffeemug tests'
          if callback
            if typeof callback is 'function'
              callback()

task 'build', 'Compile all coffeescript into javascript', build

test = (callback)->
  # run all tests, and only call the callback if they all pass
  #mocha_proc = child_process.spawn 'mocha' ,['--compilers','coffee:coffee-script','--colors','-R','list']
  say 'running tests...'
  
  mocha_proc = child_process.spawn 'mocha' ,['--colors','-R','spec']
  

  mocha_proc.stdout.pipe(process.stdout, end:false )
  mocha_proc.stderr.pipe(process.stderr, end:false )
  mocha_proc.on 'exit',(code)->
    if code == 0
      say 'all tests passed'
      if callback
        callback()
    else
      say 'TEST FAIL'


task 'test', 'Run all mocha tests', ->
  build ->
    test()


task 'doc','generate "coffeemug_docs.html" using tests as examples', ->
  build ->
    test ->
      g = require './generate_docs'
      g.generate_docs ->
        say 'task "doc" is complete'

