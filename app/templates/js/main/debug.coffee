if DEBUG
  console.log '--- DEBUG MODE ---'

  _date = +new Date()
  
  $ ->
    console.log "jQuery's 'ready' event fired: #{ +new Date() - _date } ms"
    
  $w.on 'load', ->
    console.log "'load' event fired: #{ +new Date() - _date } ms"

  # client-side benchmarking with benchmark.js
  suite = new Benchmark.Suite

  suite
  .on 'cycle', (event) ->
    console.log String(event.target)
  .on 'complete', ->
    console.log 'Fastest is ' + this.filter('fastest').pluck('name')
    