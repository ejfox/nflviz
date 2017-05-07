d3 = require('d3')
_ = require('lodash')

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
  #listPlays oaklandNestedGames[1]
  vizGame oaklandNestedGames[2]
)

vizGame = (data) ->
  gameId = data.key
  data = data.values
  console.log('game data!', data[0])

  width = 1400
  height = 1200

  playTypeScale = d3.scaleOrdinal(d3.schemeCategory10)

  svg = d3.select('#container')
    .append('svg')
    .attr('width', width)
    .attr('height', height)

  svg.selectAll('circle')
    .data(data)
    .enter().append('circle')
    .attr('class', 'playstroke')
    .attr('cx', width / 2)
    .attr('cy', height / 2)
    .attr('r', (d,i) -> i * 5 )
    .style('fill', 'transparent')
    .style('opacity', (d) ->
      if +d.Down is 4
        return '0.2'
      else if +d.Down is 3
        return '0.4'
      else if +d.Down is 2
        return '0.6'
      else
        return '1'
    )
    .style('stroke', (d) ->
      ###
      # Color by pass
      if +d.IsPass is 1
        return 'red'
      else
        return 'black'
      ###

      # Color by Series first down
      if +d.SeriesFirstDown is 1
        return 'red'
      else
        return 'black'

      #playTypeScale d.PlayType
    )
    .style('stroke-width', (d) ->
      if +d.IsPass is 1
        return 2
      else
        return 2
    )

listPlays = (data) ->
  gameId = data.key
  data = data.values
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
