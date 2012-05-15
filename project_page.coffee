
module.exports = (project)->

  @doctype 'html'
  @html ->
    @head ->

      @style """
      body{
        font-family:Arial;
      }
      .highlighted{
        color: orange
      }
      div.features{
        padding:10px;
        color:green;
      }
      """
      @script src:'//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js'

      @script ->
        sum = 0
        for n in [1,2,3]
          sum += n
        ($ 'body').append $ "<p>The total is #{sum}</p>"


    @body ->
      @h1  project.name, class:'highlighted', id:'main-title'
      @h3  project.description
      @a href:project.url, "on GitHub"

      @img src:'kitten.jpg'

      @div class:'features', style:'background:lightyellow', ->
        @h3 'Features:'
        @ul ->
          for feature in project.features
            @li feature
