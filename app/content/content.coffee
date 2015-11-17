$ = require "jquery"
_ = require "lodash"

chrome.runtime.onMessage.addListener (req, sender, send_response) ->
  response = []
  site_name = "#{location.protocol}//#{location.host}"

  $(req.context).each ->
    src = $(req.image, @).attr("src")
    unless src.startsWith("http") then src = "#{site_name}/#{_.trimLeft src, "/"}"
    response.push
      title: $(req.title, @).text()
      image: src
      info: $(req.info, @).html()
      price: $(req.price, @).text()
      short: $(req.short, @).html()
      parse_url: location.href
      link: $(req.link, @).attr "href"

  send_response response
