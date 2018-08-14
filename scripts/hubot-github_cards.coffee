# Description:
#   Example scripts for you to examine and try out.
#
# Dependencies:
#
# Configuration:
# 
# Commands: 
#   hubot list (gho|hubot-github) commands - Displays a card with buttons to run any command in the hubot-github package
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
# start of the command to the first user input marked by ( or <
constructShortQuery = (commandKeywords) ->
    shortQueryEnd = commandKeywords.search(new RegExp("[(<]"))
    if shortQueryEnd == -1
        shortQueryEnd = commandKeywords.length
    return commandKeywords.substring(0, shortQueryEnd).trim()

module.exports = (robot) ->
    # List hubot-github commands
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
                invokePayload = {
                    # 'hubotMessage': "hubot " + commandKeywords
                    'hubotMessage': commandKeywords
                }

                item = ListCardHelpers.createListResultItem(shortQuery, parts[1], invokePayload.hubotMessage)
                items.push(item)
        card.content.items = items

        response.attachments = [card]
        res.send(response)