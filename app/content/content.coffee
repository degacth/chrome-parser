$ = require "jquery"
_ = require "lodash"

chrome.runtime.onMessage.addListener (req, sender, send_response) ->
  response = []
  site_name = "#{location.protocol}//#{location.host}"

  $(req.context).each ->
    response.push
      title: $(req.title, @).text()
      image: "#{site_name}/#{_.trimLeft $(req.image, @).attr("src"), "/"}"
      info: $(req.info, @).html()
      price: $(req.price, @).text()
      short: $(req.short, @).html()
      parse_url: location.href

  send_response response
