$ ->
  getScrollTop = ->
    document.documentElement.scrollTop or document.body.scrollTop
  
  $section = $ '.faeatured-works'

  #セクションに関する数値を予め格納しておき、ループごとに取得するのを避けるための関数
  setSectionRange = ->
    $section.each (index) ->
      _$elm = $ this
      
      # セクションの左端、または上端の座標と、右端、または下端の座標
      $section[index].elmStart = _$elm.position().top
      $section[index].elmEnd = $section[index].elmStart + _$elm.height()
        
      _outerHeight = _$elm.outerHeight()
      
      adjustLength = $w.height()

      # スクロールイベントの境界
      $section[index].rangeStart = $section[index].elmStart - adjustLength * 0.25
      $section[index].rangeEnd = $section[index].elmEnd - adjustLength * 0.10
      
      $section[index].$inner = _$elm.find '.wide-image'
      
      return
  
  setSectionRange()
     
  $w.on 'resize', null, ->
    setSectionRange()
   
  $w.on 'scroll', null, ->
    _scrollDistance = getScrollTop()
    
    for elm, i in $section
      if elm.rangeStart < _scrollDistance < elm.rangeEnd
        elm.$inner.safeAnimate {
          'opacity': '1'
        }, 275
        console.log i
      else
        if _scrollDistance < elm.elmStart and elm.elmEnd < _scrollDistance
          elm.style.opacity = '1'
        else
          
          elm.$inner.safeAnimate {
            'opacity': '0.8'
          }, 275
        
        
      
