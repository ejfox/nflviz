d3 = require('d3')
_ = require('lodash')
moment = require('moment')
$ = require('jquery')
oaklandNestedGames = []
gameNum = 1

width = $(window).width()#1400
height = $(window).height()#1200

t = d3.transition()
  .duration(1250)
  .ease(d3.easeQuad)

container = d3.select('#container')
controls = container.append('div').attr('id', 'controls')
tooltip = container.append('div').attr('id', 'tooltip')

svg = container
  .append('svg')
  .attr('width', width)
  .attr('height', height)

d3.csv('data/pbp-2016.csv', (plays) ->
  oaklandPlays = _.filter(plays, (play) ->
    if play.DefenseTeam is 'OAK'
      true
    else if play.OffenseTeam is 'OAK'
      true
    else
      false
  )

  oaklandNestedGames = d3.nest()
    .key((d) ->
      return d.GameId
    )
    .entries(oaklandPlays)

  #listGames oaklandNestedGames

  loadGame(1)
  #listPlays oaklandNestedGames[game]
)

nextGame = ->
  game = gameNum + 1
  loadGame game

loadGame = (game) ->
  gameNum = game
  vizGame oaklandNestedGames[game]

sortGameByTime = (data) ->
  data.forEach( (game) ->
    min = game.Minute
    sec = game.Second
    playTime = moment({
      minute: min
      ,second: sec
    })
    game.Timestamp = +playTime
  )

  data = _(data).chain()
    .sortBy('Timestamp')
    .sortBy('Quarter')
    .value()

onlyShow = (metric) ->
  svg = d3.select('svg')

  label = d3.select('#centerlabel')
    .text(metric)

  svg.selectAll('circle').transition(t)
    .style('opacity', (d) ->
      if +d[metric] is 1
        return 1
      else
        return 0
    )

vizGame = (data) ->
  gameId = data.key
  data = data.values
  data = sortGameByTime(data)

  console.log('game data!', data[0], data)

  playTypeScale = d3.scaleOrdinal(d3.schemeCategory10)

  label = d3.select('#centerlabel')
    .style('top', height/2.15+'px')
    #.style('left', width/2+'px')
    .text( (d) ->
      data[10].OffenseTeam + ' vs ' + data[10].DefenseTeam
    )

  circle = svg.selectAll('circle')
    .data(data)

  circle.exit().remove()

  circle.enter().append('circle')
    .attr('cx', width / 2)
    .attr('cy', height / 2)
    .attr('r', (d,i) -> i * 5 )
    .style('fill', 'none')
    .on('mouseover', (d) ->
      coords = d3.mouse(this)
      tooltip.text(d.Description)
      padding = 14
      tooltip.style('left', ( coords[0] + padding ) + 'px')
      tooltip.style('top', ( coords[1] + padding ) + 'px')

      d3.select(this).style('stroke', 'red')
    )
    .on('mouseout', (d) ->
      d3.select(this).style('stroke', (d) ->
        # Color by pass
        if +d.IsTouchdown is 1
          return 'green'
        else
          return 'black'
      )
    )

  svg.selectAll('circle').transition(t)
    .attr('class', 'playstroke')
    .style('opacity', (d) ->
      ###
      else if +d.Down is 4
        return 0.2
      else if +d.Down is 3
        return 0.4
      else if +d.Down is 2
        return 0.6
      else
        return 1
      ###
    )
    .style('stroke', (d) ->
      # Color by pass
      if +d.IsTouchdown is 1
        return 'green'
      else
        return 'black'


      ###
      # Color by Series first down
      if +d.SeriesFirstDown is 1
        return 'red'
      else
        return 'black'
      ###

      #return playTypeScale d.Quarter
      #return 'black'
      #playTypeScale d.PlayType
    )
    .style('stroke-width', (d) ->
      ###
      if +d.IsPass is 1
        return 2
      else
        return 1
      ###

      if d.DefenseTeam is 'OAK'
        2
      else
        1
    )
  ###
  .style('stroke-dasharray', (d) ->
  if +d.IsTouchdown is 1
    '5,5'
  else
    ''
  )
  ###
  controls.html('')
  controls.append('button')
    .text('Pass')
    .on 'mousedown', -> onlyShow('IsPass')

  controls.append('button')
    .text('Rush')
    .on 'mousedown', -> onlyShow('IsRush')

  controls.append('button')
    .text('Fumble')
    .on 'mousedown', -> onlyShow('IsFumble')

  controls.append('button')
    .text('Incomplete')
    .on 'mousedown', -> onlyShow('IsIncomplete')

  controls.append('button')
    .text('Load Game 10')
    .on 'mousedown', -> loadGame(10)

  controls.append('button')
    .text('Load Game 5')
    .on 'mousedown', -> loadGame(5)

  controls.append('button')
    .text('Next Game')
    .on 'mousedown', -> nextGame()

listPlays = (data) ->
  gameId = data.key
  data = data.values
  data = sortGameByTime(data)
  console.log('game data!', data[0])

  container = d3.select('#container')
    .append('div').attr('id', 'game')

  container.selectAll('p')
    .data(data)
    .enter().append('p')
    .style('border-bottom', '1px solid black')
    .style('font-size', 10)
    .html((d) ->
      return d.Description
    )

listGames = (data) ->
  container = d3.select('#container')
    .append('div').attr('id', 'gamelist')

  games = container.selectAll('div')
    .data(data)
    .enter().append('div')
    .html((d) ->
      htmlString = d.key + ' '
      htmlString += d.values[0].OffenseTeam + ' vs ' + d.values[0].DefenseTeam
      return htmlString
    )
