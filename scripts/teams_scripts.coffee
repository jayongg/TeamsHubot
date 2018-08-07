# Description:
#   Example scripts for you to examine and try out.
#
# Dependencies:
#
# Configuration:
# Put environment variables needed to run these here
# 
# Commands: 
# hubot admins - Lists the designated admins when using hubot with Microsoft Teams
# hubot authorized users - Lists the authorized users when using hubot with Microsoft Teams
#
# Author:
#   t-memend

# Note: Only the commands available to all authorized users are listed in help
# commands and not admin only commands.

BotBuilder = require('botbuilder')

# Helper functions
escapeLessThan = (str) ->
  return str.replace(/</g, "&lt;")

escapeNewLines = (str) ->
  return str.replace(/\n/g, "<br/>")

module.exports = (robot) ->
  # Admin only commands #################################
  # Authorize a user to send commands to hubot
  robot.respond /authorize ([a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12})/i, (res) ->
    user = res.match[1]
    authorizedUsers = robot.brain.get("authorizedUsers")

    # Don't do anything if authorization isn't enabled
    if authorizedUsers is null
      return

    # Check the user is an admin
    if !authorizedUsers[res.message.user.aadObjectId]
      res.send "Only admins can authorize users"
      return

    # Check the user hasn't already been authorized
    if authorizedUsers[user]?
      res.send("The user is already authorized")
      return
  
    # Users are not an admin by default
    authorizedUsers[user] = false
    robot.brain.remove("authorizedUsers")
    robot.brain.set("authorizedUsers", authorizedUsers)
    res.send("The user has been authorized")


  # Remove authorization of a user to send commands to hubot
  robot.respond /unauthorize ([a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12})/i, (res) ->
    sender = res.message.user.aadObjectId
    user = res.match[1]
    authorizedUsers = robot.brain.get("authorizedUsers")

    # Don't do anything if authorization isn't enabled
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
      res.send "The user already isn't authorized"
      return
    
    delete authorizedUsers[user]
    robot.brain.remove("authorizedUsers")
    robot.brain.set("authorizedUsers", authorizedUsers)
    res.send("The user has been unauthorized")


  # Make a user an admin
  robot.respond /make ([a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12}) an admin/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    user = res.match[1]

    # Don't do anything if authorization isn't enabled
    if authorizedUsers is null
      return

    # Check the sender is an admin
    if !authorizedUsers[res.message.user.aadObjectId]
      res.send "Only admins can add admins"
      return

    # Only authorized users can be made admins
    if authorizedUsers[user] is undefined
      res.send "The user isn't authorized. Please authorize them first"
      return

    # Check user isn't already an admin
    if authorizedUsers[user]
      res.send("The user is already an admin")
      return
    
    authorizedUsers[user] = true
    robot.brain.remove("authorizedUsers")
    robot.brain.set("authorizedUsers", authorizedUsers)
    res.send("The user is now an admin")

  
  # Remove an admin
  robot.respond /remove ([a-z0-9]{8}(-[a-z0-9]{4}){3}-[a-z0-9]{12}) from admins/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    sender = res.message.user.aadObjectId
    user = res.match[1]
    
    # Don't do anything if authorization isn't enabled
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
      res.send "The user already isn't an admin"
      return

    authorizedUsers[user] = false
    robot.brain.remove("authorizedUsers")
    robot.brain.set("authorizedUsers", authorizedUsers)
    res.send("The user has been removed as an admin")


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

    # Don't do anything if authorization isn't enabled
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

    # Don't do anything if authorization isn't enabled
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

  #############################
  # For returning message when unauthorized user tries to send a message
  robot.respond /return unauthorized user error/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")

    # Don't do anything if authorization isn't enabled
    if authorizedUsers is null
      return

    text = "You are not authorized to send commands to hubot. Please talk to your admins:"
    for user, isAdmin of authorizedUsers
      if isAdmin
        # if text == ""
        #   text = user
        # else
          text = """#{text}<br>- #{user}"""
    text = """#{text}<br> to be authorized."""
    res.send(text)
  
  # For returning message when authorization is enabled and a message from a source
  # that doesn't support authorization is received
  robot.respond /return source authorization not supported error/i, (res) ->
    console.log("IN UNSUPPORTED AUTH ERROR")
    res.send("Authorization isn't supported for this channel")

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

  # Testing
  robot.respond /list commands/i, (res) ->
    res.send "MS Teams Command list card"

  # Testing admins card, for multiline
  robot.respond /list admins/i, (res) ->
    res.send "List the admins"

  ####################################
  # Commands for receiving answer to user inputs for hubot commands (ex: pug me N, for receiving N)
  # Allows up to 2048 characters (for now)
  # *** Think of a better way of receiving user input, LIKE ADAPTIVE CARDS
  # maybe this can just be a temporary fix until adaptive cards can imback ***
  # robot.respond /(.+){1,2048}/i, (res) ->
  #   # When this command is supposed to do nothing
  #   if context == ""
  #     return
    
  #   if MultiDialogContext == "gho create team"
  #     teamName = res.match[1]


    
