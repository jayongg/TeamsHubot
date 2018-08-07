# Description:
#   Example scripts for you to examine and try out.
#
# Dependencies:
#
# Configuration:
# Put environment variables needed to run these here
# 
# Note: Only the commands available to all authorized users are listed in help
# commands and not admin only commands.
# Commands: 
#
# Author:
#   t-memend

BotBuilder = require('botbuilder')
ListCardHelpers = require('./list_card_helpers')


# Helper functions

initializeResponse = (res) ->
    response =
            type: 'message'
            address: res?.message?.user?.activity?.address
    return response

# Converts < into the HTML escaped version
escapeLessThan = (str) ->
  return str.replace(/</g, "&lt;")

# Converts \n into break tags
escapeNewLines = (str) ->
  return str.replace(/\n/g, "<br/>")

# Create a short version of the command by including only the
# start of the command to the first user input marked by ( or <
constructShortQuery = (commandKeywords) ->
    shortQueryEnd = commandKeywords.search(new RegExp("[(<]"))
    if shortQueryEnd == -1
        shortQueryEnd = commandKeywords.length
    return commandKeywords.substring(0, shortQueryEnd)

module.exports = (robot) ->
    # List hubot-github commands (minus gho until it doesn't break Bot Framework)
    robot.respond /list (gho|hubot-github) commands/i, (res) ->
        # *** Adaptive card with too many follow up buttons
        # can only show up to 6 and it's cut off
        # res.send('list (gho|hubot-github) commands')
        # return

        response = initializeResponse(res)

        heroCard = new BotBuilder.HeroCard()
        heroCard.title('hubot-github (gho) commands')
        buttons = []
        text = ""
        for command in @robot.commands
            if command.search(" gho ") != -1
                parts = command.split(" - ")
                commandKeywords = parts[0].replace("hubot ", "")

                commandText = parts[0] + " - " + parts[1]
                if text == ""
                    text = commandText
                else
                    text = "#{text}\n#{commandText}"

                button = new BotBuilder.CardAction.invoke()
                shortQuery = constructShortQuery(commandKeywords)
                button.title(shortQuery)

                # *** changing to invoke action
                invokePayload = {
                    'hubotMessage': commandKeywords
                }
                # If the command needs user input, generate an adaptive
                # card for it
                if (shortQuery != commandKeywords)
                    invokePayload.hubotMessage = "generate input card " + shortQuery
                button.value(invokePayload)

                buttons.push button

        heroCard.buttons(buttons)

        text = text.replace(/</g, "&lt;")
        text = text.replace(/\n/g, "<br>")
        heroCard.text(text)

        if text != ""
            response.attachments = [heroCard.toAttachment()]
            res.send(response)
        else
            res.send("No hubot-github commands found")

    #########################################
    # Commands for generating adaptive cards with inputs. Used for
    # menu cards.
    robot.respond /generate input card gho list/i, (res) ->
        res.send("gho list (teams|repos|members)")
    
    robot.respond /generate input card gho create team/i, (res) ->
        res.send("gho create team <team name>")

    robot.respond /generate input card gho create repo/i, (res) ->
        res.send("gho create repo <repo name>/<private|public>")

    robot.respond /generate input card gho add/i, (res) ->
        res.send("gho add (members|repos) <members|repos> to team <team name>")

    robot.respond /generate input card gho remove/i, (res) ->
        res.send("gho remove (repos|members) <members|repos> from team <team name>")
    
    robot.respond /generate input card gho delete team/i, (res) ->
        res.send("gho delete team <team name>")

    ###############################################
    # For creating a list card version of the command menu
    # actions are invokes.
    robot.respond /list card me/i, (res) ->
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
                    'hubotMessage': commandKeywords
                }
                # If the command needs user input, generate an adaptive
                # card for it
                if (shortQuery != commandKeywords)
                    invokePayload.hubotMessage = "generate input card " + shortQuery
                item = ListCardHelpers.createListResultItem(shortQuery, parts[1], invokePayload.hubotMessage)
                items.push(item)

        card.content.items = items

        # card = {
        #     "contentType": "application/vnd.microsoft.teams.card.list",
        #     "content": {
        #         "title": "Card title",
        #         "items": [ {
        #                 "type": "file",
        #                 "id": "https://contoso.sharepoint.com/teams/new/Shared%20Documents/Report.xslx",
        #                 "title": "Report",
        #                 "subtitle": "teams > new > design",
        #                 "tap": {
        #                     "type": "invoke",
        #                     "value": {
        #                         'hubotMessage': "generate input card gho list "
        #                     }
        #                 }
        #             },
        #             {
        #                 "type": "resultItem",
        #                 "icon": "https://cdn2.iconfinder.com/data/icons/social-icons-33/128/Trello-128.png",
        #                 "title": "Trello title",
        #                 "subtitle": "A Trello subtitle",
        #                 "tap": {
        #                     "type": "openUrl",
        #                     "value": "http://trello.com"
        #                 }
        #             },
        #             {
        #                 "type": "section",
        #                 "title": "Manager"
        #             },
        #             {
        #                 "type": "person",
        #                 "id": "JohnDoe@contoso.com",
        #                 "title": "John Doe",
        #                 "subtitle": "Manager",
        #                 "tap": {
        #                     "type": "imBack",
        #                     "value": "whois JohnDoe@contoso.com"
        #                 }
        #             }
        #         ],
        #         "buttons": [ {
        #                 "type": "imBack",
        #                 "title": "Select",
        #                 "value": "whois"
        #             }
        #         ]
        #     }
        # }

        response.attachments = [card]
        res.send(response)