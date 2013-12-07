$ ->
  $main = $ 'main'

  urlContains = (string) ->
    location.pathname.indexOf(string) isnt -1

  # 外部リンクと bxSlider の UI には pjax を適用しない
  if $.support.pjax
    $('#container').on 'click', 'a:not([target])', (e) ->
      e.preventDefault()

      $main.fadeTo 4, 0.010, ->
        $.pjax.click e, {
          container: '#content'
          fragment: '#content'
          timeout: 36000
        }

  resetContent = (e, xhr) ->
    
    # set page title
    if xhr?.getResponseHeader 'X-PJAX-Title'
      document.title = xhr.getResponseHeader 'X-PJAX-Title'
    
    # top page
    if location.href.indexOf('projects') is -1 and
    location.href.indexOf('about') is -1
      $main.addClass 'top'
      $w.on 'resize pjax:end', setTitlePos

      setTitlePos()
      
      $w.one 'scroll', resetTop
      $('#scroll-down').on 'click', ->
        $('html,body').animate {
          scrollTop: "#{ $('header').height() }px"
        }, 400
        resetTop()
        
      $('img[data-original]')
      .removeAttr('src')
      .lazyload
        effect : 'fadeIn'
        threshold : $w.height() * 0.25
        skip_invisible: false
        placeholder: '/img/transparent.gif'
        
      $('#logo').transition {
        backgroundPosition: '0px 0px'
      }, 500
      
    else
      $main.removeClass 'top'
    
    if urlContains 'projects/'
      $('img[data-original]')
      .removeAttr('src')
      .lazyload
        effect: 'fadeIn'
        threshold: $w.height() * 0.5
        effect_speed:
          start: ->
            $this = $ this
            if $this.is '.project-image:eq(0)'
              $main.stop().fadeTo 150, 1
              $this.finish()
          always: ->
            # 「'.image-wrapper' の子孫である」要素に限定せずに .unwrap() すると、
            # ブラウザバックのたびに親要素を一つずつ消していってしまう
            $('.image-wrapper').find(this).unwrap()

    if urlContains 'projects.htm'
      $('img[data-original]')
      .removeAttr('src')
      .lazyload
        effect : 'fadeIn'
        threshold : $w.height() * 0.15
        placeholder: '/img/transparent.gif'
  
  resetTop = ->
    # Open the ribbon
    $('#scroll-down').fadeOut 80, ->
      $(this).remove()
    $('#left-ribbon, #right-ribbon').transition {
      width: 0
    }, 250, ->
      $('#ribbon').remove()
    
    $('.top .inner').transition {
      paddingTop: '0'
    }, 400
    
    $('.wide-image').css 'width', '100%'
    
    $('.featured-works')
    .css('visibility', 'visible')
    .fadeTo 750, 1
    
    $w.off 'resize pjax:end', setTitlePos

  setTitlePos = ->
    $('.top .inner').css {
      paddingTop: "#{ Math.max($w.height() * 0.5 - 350, 0) }px"
    }

  _activateTab = ->
    $("#home.active, #tabs > .active").removeClass('active')

    for page, i in ['about', 'project']
      if urlContains page
        $('#tabs > a').eq(i+1).addClass('active')
        break

      if i is 1
        $("#tabs > a").eq(0)
        .addClass('active')

  # initialize
  resetContent()

  $doc.on 'pjax:start ready', ->
    _activateTab()
  
  $doc.on 'pjax:end', resetContent
  
  $doc.on 'pjax:complete', ->
    unless urlContains 'projects/'
      $main.stop().fadeTo 150, 1
    
