# Description:
#   Scripts for controlling authorization with Teams for use with the botframework adapter
#
# Dependencies:
#
# Configuration:
#
# Commands: 
#   hubot admins - Lists the designated admins when using hubot with Microsoft Teams
#   hubot authorized users - Lists the authorized users when using hubot with Microsoft Teams
#
# Author:
#   t-memend

# Note: Only the commands available to all authorized users are listed in help
# commands and not admin only commands.

BotBuilder = require('botbuilder')

module.exports = (robot) ->
  # ##########################################
  # Admin only commands

  # Authorize a user to send commands to hubot
  robot.respond /authorize ([a-zA-Z0-9\-_.]+@([a-zA-Z0-9]+)(.([a-zA-Z0-9]+)){1,2})$/i, (res) ->
    user = res.match[1].toLowerCase()
    authorizedUsers = robot.brain.get("authorizedUsers")

    # Don't do anything if authorization isn't enabled
    if authorizedUsers is null
      return

    # Check the user is an admin
    if !authorizedUsers[res.message.user.userPrincipalName]
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
  robot.respond /unauthorize ([a-zA-Z0-9\-_.]+@([a-zA-Z0-9]+)(.([a-zA-Z0-9]+)){1,2})$/i, (res) ->
    sender = res.message.user.userPrincipalName
    user = res.match[1].toLowerCase()
    authorizedUsers = robot.brain.get("authorizedUsers")

    # Don't do anything if authorization isn't enabled
    if authorizedUsers is null
      return

    # Check the sender is an admin
    if !authorizedUsers[res.message.user.userPrincipalName]
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
  robot.respond /make ([a-zA-Z0-9\-_.]+@([a-zA-Z0-9]+)(.([a-zA-Z0-9]+)){1,2}) an admin$/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    user = res.match[1].toLowerCase()

    # Don't do anything if authorization isn't enabled
    if authorizedUsers is null
      return

    # Check the sender is an admin
    if !authorizedUsers[res.message.user.userPrincipalName]
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
  robot.respond /remove ([a-zA-Z0-9\-_.]+@([a-zA-Z0-9]+)(.([a-zA-Z0-9]+)){1,2}) from admins$/i, (res) ->
    authorizedUsers = robot.brain.get("authorizedUsers")
    sender = res.message.user.userPrincipalName
    user = res.match[1].toLowerCase()
    
    # Don't do anything if authorization isn't enabled
    if authorizedUsers is null
      return

    # Check the sender is an admin
    if !authorizedUsers[res.message.user.userPrincipalName]
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


  # ############################
  # Authorized User commands

  # List admins
  robot.respond /admins$/i, (res) ->
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
  robot.respond /authorized users$/i, (res) ->
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