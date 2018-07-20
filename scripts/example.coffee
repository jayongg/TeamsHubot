# Description:
#   Example scripts for you to examine and try out.
#
# Dependencies:
#
# Configuration:
# 
# Commands:
#
# Author:
#   t-memend

BotBuilder = require('botbuilder')

module.exports = (robot) ->
  # Admin only commands #################################
  # Authorize a user to send commands to hubot
  robot.respond /authorize ([a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12})/i, (res) ->
    user = res.match[1]
    authorizedUsers = robot.brain.get("authorizedUsers")

    # Don't do anything if the adapter isn't being used
    if authorizedUsers is null
      return

    # Check the user is an admin
    if !authorizedUsers[res.message.user.aadObjectId]
      res.send "Only admins can authorize users"
      return

    # Check the user hasn't already been authorized
    if authorizedUsers[user]?
      res.send(user + " is already authorized")
      return
  
    # Users are not an admin by default
    authorizedUsers[user] = false
    robot.brain.remove("authorizedUsers")
    robot.brain.set("authorizedUsers", authorizedUsers)
    res.send(user + " has been authorized")


  # Remove authorization of a user to send commands to hubot
  robot.respond /unauthorize ([a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12})/i, (res) ->
    sender = res.message.user.aadObjectId
    user = res.match[1]
    authorizedUsers = robot.brain.get("authorizedUsers")

    # Don't do anything if the adapter isn't being used
    if authorizedUsers is null
      return

    # Check the sender is an admin
    if !authorizedUsers[res.message.user.aadObjectId]
      res.send "Only admins can unauthorize users"
      return

    # An admin can't remove themself
    if sender == user
      res.send "You can't unauthorize yourself!"
      return

    # Check that user isn't already unauthorized
    if authorizedUsers[user] is undefined
      res.send "#{user} already isn't authorized"
      return
    
    delete authorizedUsers[user]
    robot.brain.remove("authorizedUsers")
    robot.brain.set("authorizedUsers", authorizedUsers)
    res.send(user + " has been unauthorized")


  # Make a user an admin
  robot.respond /make ([a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12}) an admin/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    user = res.match[1]

    # Don't do anything if the adapter isn't being used
    if authorizedUsers is null
      return

    # Check the sender is an admin
    if !authorizedUsers[res.message.user.aadObjectId]
      res.send "Only admins can add admins"
      return

    # Only authorized users can be made admins
    if authorizedUsers[user] is undefined
      res.send "#{user} isn't authorized. Please authorize them first"
      return

    # Check user isn't already an admin
    if authorizedUsers[user]
      res.send("#{user} is already an admin")
      return
    
    authorizedUsers[user] = true
    robot.brain.remove("authorizedUsers")
    robot.brain.set("authorizedUsers", authorizedUsers)
    res.send(user + " is now an admin")

  
  # Remove an admin
  robot.respond /remove ([a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12}) from admins/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    sender = res.message.user.aadObjectId
    user = res.match[1]
    
    # Don't do anything if the adapter isn't being used
    if authorizedUsers is null
      return

    # Check the sender is an admin
    if !authorizedUsers[res.message.user.aadObjectId]
      res.send "Only admins can remove admins"
      return

    # Admins can't remove themself
    if sender == user
      res.send "You can't remove yourself as an admin"
      return

    # Check user is an admin
    if authorizedUsers[user] is undefined || !authorizedUsers[user]
      res.send "#{user} already isn't an admin"
      return

    authorizedUsers[user] = false
    robot.brain.remove("authorizedUsers")
    robot.brain.set("authorizedUsers", authorizedUsers)
    res.send(user + " has been removed as an admin")


  # *** For testing utility #####################
  robot.respond /N/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    delete authorizedUsers[process.env.AADOBJECTID]
    console.log(authorizedUsers)

  robot.respond /Y/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    authorizedUsers[process.env.AADOBJECTID] = true
    console.log(authorizedUsers)

  robot.respond /ln/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    authorizedUsers[process.env.AADOBJECTID] = false
    console.log(authorizedUsers)

  robot.respond /ly/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    authorizedUsers[process.env.AADOBJECTID] = true
    console.log(authorizedUsers)


  # Lay person commands ######################
  # List admins
  robot.respond /admins/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    console.log("********HEY********************************")
    console.log(authorizedUsers is undefined)
    console.log(authorizedUsers is null)

    # Don't do anything if the adapter isn't being used
    if authorizedUsers is null
      return

    text = ""
    for user, isAdmin of authorizedUsers
      if isAdmin
        if text == ""
          text = user
        else
          text = """#{text}
                    #{user}"""

    if text == ""
      res.send("There's no admins")
    else
      res.send("#{text}")
  
  # List authorized users
  robot.respond /authorized users/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")

    # Don't do anything if the adapter isn't being used
    if authorizedUsers is null
      return

    text = ""
    for user of authorizedUsers
      if text == ""
        text = user
      else
        text = """#{text}
                  #{user}"""
    res.send("#{text}")
  
  # *** Testing getting page
  robot.respond /setup Teams/i, (res) ->
    robot.http("https://dev.botframework.com/bots/new")
    .get() (err, res, body) ->
      if err
        res.send "Encountered an error :( #{err}"
        return
      # your code here, knowing it was successful
      console.log(res)
  
  # *** Testing sending back hero card
  robot.respond /hero card me/i, (res) ->
    res.send("unicorns")

  # *** Testing sending back adaptive card
  robot.respond /adaptive card me/i, (res) ->
    res.send("dragons")

  # Badgers
  robot.hear /badger/i, (res) ->
    res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  robot.enter (res) ->
    res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
