'use strict'

if not DEBUG?
  this.DEBUG = true

ua = navigator.userAgent

isMobile = do ->
  return ua.indexOf('like Mac OS X') isnt -1 or
         ua.indexOf('Android') isnt -1 or
         (ua.indexOf('Mobile') isnt -1 and ua.indexOf('Firefox') isnt -1)

$w = $ window
$doc = $ document

# 'safeAnimate' メソッド - アニメーション開始前に、それまでのアニメーションを中止する
jQuery.fn.safeAnimate = do ->
  _protoSlice = Array::slice
  
  return ->
    args = _protoSlice.call arguments, 0
    return this.stop().animate args...

if not $.support.transition
  $.fn.transition = $.fn.animate
