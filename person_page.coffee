
module.exports = (person)->

  @doctype 'html'
  @html ->
    @head ->

      @style """
      body{
        font-family:Arial;
      }
      .highlighted{
        color: green
      }
      """

      @script ->
        sum = 0
        for n in [1,2,3]
          sum += n


    @body ->
      @h1  person.name, class:'highlighted', id:'main-title'
      @h3 'age: '+person.age
      @div style:'background:lightyellow', ->
        @hr '-----'
        @h3 'Numbers:'
        @ul ->
          for n in person.numbers
            @li n
        @h3 'Kids:'
        @ul ->
          for kid in person.kids
            @li kid.name + ' ('+kid.age+')'


