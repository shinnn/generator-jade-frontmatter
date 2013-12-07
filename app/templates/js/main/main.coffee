# 右上に表示する要素
go = $ '<div id="go"></div>'

$('.wzide-image')
.on 'mouseover', ->
  $(this).children('img').animate {
    'border-width': '24px'
    'top': '-12px'
    'left': '-12px'
  }, 100
  
  go.css 'top', - $(this).children('img').height() + 'px'
  $(this).append go

.on 'mouseout', ->
  $(this).children('img').animate {
    'opacity': '1'
  }, 100
  
  go.remove()