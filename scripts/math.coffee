# Description:
#   Allows Hubot to do mathematics.
#   https://github.com/jgable/hubot-irc-runnable の改造版
#
# Commands:
#   "calc: 1+1" で計算できる
#   ACCEPT_ROOMSに入っている部屋ではcalcをつけなくてもOK
module.exports = (robot) ->
  ACCEPT_ROOMS = ["example"]
  robot.hear /(gcalc|calc|calculate|convert|math)?(:|>)?\s*(.*)\s*/i, (msg) ->
    formula = msg.match[3]
    room = msg.message.room.replace(/^#(.*?)(@\w+)?$/, -> RegExp.$1)
    perhapsFormula = formula.match(/^([0-9\.\-\*\/\+   =\(\)]+)$/)
    console.log("式っぽい: "+formula) if perhapsFormula
    return if !msg.match[1] && !perhapsFormula
    #console.log("許可リストに入っている部屋です") if room in ACCEPT_ROOMS
    return if !msg.match[1] && !(room in ACCEPT_ROOMS)
    console.log("計算を行います")
    convertResult = (result) ->
      result = result.replace(/&#215;/g, "*")
      result = result.replace(/<sup>(.*?)<\/sup>/g, -> "^"+RegExp.$1)
    msg
      .http('http://www.google.com/ig/calculator')
      .query
        hl: 'ja'
        q: formula
      .headers
        'Accept-Language': 'en-us,en;q=0.5',
        'Accept-Charset': 'utf-8',
        'User-Agent': "Mozilla/5.0 (X11; Linux x86_64; rv:2.0.1) Gecko/20100101 Firefox/4.0.1"
      .get() (err, res, body) ->
        # Response includes non-string keys, so we can't use JSON.parse here.
        json = eval("(#{body})")
        msg.send json.lhs + " = " + convertResult(json.rhs) if json.rhs