# Description:
#   Command for listing all of the commands in the hubot-github package when using the
#   botframework adapter. The commands are shown on a Microsoft Teams List Card which
#   contains buttons for running each of the commands on hubot
#
# Dependencies:
#   
#
# Configuration:
#   
#
# Commands: 
#   hubot list (gho|hubot-github) commands - Displays a card with buttons to run any command in the hubot-github package
#
# Author:
#   t-memend

ListCardHelpers = require('./list_card_helpers')

# Helper functions
initializeResponse = (res) ->
    response =
            type: 'message'
            address: res?.message?.user?.activity?.address
    return response

# Create a short version of the command by including only the
# start of the command to the first user input, marked by ( or <.
# Trims whitespace from the short version of the command.
constructShortQuery = (commandKeywords) ->
    shortQueryEnd = commandKeywords.search(new RegExp("[(<]"))
    if shortQueryEnd == -1
        shortQueryEnd = commandKeywords.length
    return commandKeywords.substring(0, shortQueryEnd).trim()

module.exports = (robot) ->
    # List hubot-github commands on a Microsoft Teams List Card. hubot-github
    # commands are identified by the prefix 'gho' used for all of the commands
    # in the package.
    # Execution of commands on hubot are initiated using invoke actions when a
    # command is pressed.
    robot.respond /list (gho|hubot-github) commands$/i, (res) ->
        response = initializeResponse(res)

        card = ListCardHelpers.initializeListCard(res.message.text)
        items = []
        for command in @robot.commands
            if command.search(" gho ") != -1
                parts = command.split(" - ")
                commandKeywords = parts[0].replace("hubot ", "")

                commandText = parts[0] + " - " + parts[1]
                if text == ""
                    text = commandText
                else
                    text = "#{text}\n#{commandText}"

                shortQuery = constructShortQuery(commandKeywords)

                item = ListCardHelpers.createListResultItem(shortQuery, parts[1], \
                                                            "hubot " + commandKeywords)
                items.push(item)
        card.content.items = items

        response.attachments = [card]
        res.send(response)
