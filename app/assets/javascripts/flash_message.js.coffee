$ ->
  flashCallback = ->
    $(".alert").fadeOut()
  $(".alert").bind 'click', (ev) =>
    $(".alert").fadeOut()
  setTimeout flashCallback, 5000
$ ->