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
ButtonValueLUT = require('./button_value_LUT')


# Helper functions

initializeResponse = (res) ->
    response =
            type: 'message'
            address: res?.message?.user?.activity?.address
    return response

escapeLessThan = (str) ->
  return str.replace(/</g, "&lt;")

escapeNewLines = (str) ->
  return str.replace(/\n/g, "<br/>")

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

                commandText = "**" + parts[0] + "** - " + parts[1]
                if text == ""
                    text = commandText
                else
                    text = "#{text}\n#{commandText}"

                button = new BotBuilder.CardAction.imBack()

                # Create a short version of the command by including only the
                # start of the command to the first user input marked by ( or <
                shortQueryEnd = commandKeywords.search(new RegExp("[(<]"))
                if shortQueryEnd == -1
                    shortQueryEnd = commandKeywords.length
                shortQuery = commandKeywords.substring(0, shortQueryEnd)
                button.title(shortQuery)

                
                #buttonValue = commandKeywords
                button.value(commandKeywords)
                # If the command needs user input, generate an adaptive
                # card for it
                if (shortQuery != commandKeywords)
                    button.value("generate input card " + shortQuery)

                # ***
                # Go to lookup table to get value (for multi dialogs)
                # tableValue = ButtonValueLUT[commandKeywords]
                # console.log(tableValue)
                # if tableValue != undefined
                #     console.log("setting to table value")
                #     button.value(tableValue)

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
    # menu cards. *** Kind of hacky, only until they allow for rendering
    # more buttons on an adaptive card
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

    ##########################################

    # For listing a team/repo/or member
    robot.respond /gho list which/i, (res) ->
        response = initializeResponse(res)

        heroCard = new BotBuilder.HeroCard()
        heroCard.title('hubot-github list')
        heroCard.text('Which would you like to list for your GitHub organization?')
        buttons = []
        types = ["teams", "repos", "members"]
        for type in types
            button = new BotBuilder.CardAction.imBack()
            button.title(type)

            # Go to lookup table to get value (for multi dialogs)
            button.value("gho list " + "#{type}")
            buttons.push button

        heroCard.buttons(buttons)

        response.attachments = [heroCard.toAttachment()]
        res.send(response)
    
    # For creating a team with the inputted name
    robot.respond /gho create what team name/i, (res) ->
        # ***
        # If you're doing this with catch all commands
        # MultiDialogContext = "gho create team"
        # res.send("What is the name of the team to create?")

        # ***
        # If you're doing this with adaptive cards

        response = initializeResponse(res)

        card = {
            'contentType': 'application/vnd.microsoft.card.adaptive'
            'content': {
                "type": "AdaptiveCard"
                "version": "1.0"
                "body": [
                    {
                        'type': 'TextBlock'
                        'text': 'hubot-github create a team'
                        'speak': '<s>hubot-github create a team</s>'
                        'weight': 'bolder'
                        'size': 'large'
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'What is the name of the team? (Max 256 characters)'
                        
                    },
                    {
                        'type': 'Input.Text'
                        'id': 'input0'
                        'speak': '<s>What is the name of the team? Max 256 characters</s>'
                        'wrap': true
                        'style': 'text'
                        'maxLength': 256
                    }
                ],
                'actions': [
                    {
                        'type': 'Action.Submit'
                        'title': 'Submit'
                        'data': {
                            'query0': 'hubot gho create team '
                            'numInputs': 1
                        }
                    }
                ]
            }
        }
        response.attachments = [card]
        res.send(response)

    # For creating a repo with the inputted name and optional
    # public/private designation
    # For creating a team with the returned name
    robot.respond /gho create what repo name and privacy/i, (res) ->
        response = initializeResponse(res)

        card = {
            'contentType': 'application/vnd.microsoft.card.adaptive'
            'content': {
                "type": "AdaptiveCard"
                "version": "1.0"
                "body": [
                    {
                        'type': 'TextBlock'
                        'text': 'hubot-github create a repo'
                        'speak': '<s>hubot-github create a repo</s>'
                        'weight': 'bolder'
                        'size': 'large'
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'What is the name of the repo? (Max 256 characters)'
                    },
                    {
                        'type': 'Input.Text'
                        'id': 'input0'
                        'speak': '<s>What is the name of the repo? Max 256 characters</s>'
                        'wrap': true
                        'style': 'text'
                        'maxLength': 256
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'Public or private?'
                    },
                    {
                        "type": "Input.ChoiceSet"
                        "id": "input1"
                        "style": "compact"
                        "value": "public"
                        "choices": [
                            {
                                "title": "Public"
                                "value": "public"
                            },
                            {
                                "title": "Private"
                                "value": "private"
                            }
                        ]
                    }
                ],
                'actions': [
                    {
                        'type': 'Action.Submit'
                        'title': 'Submit'
                        'data': {
                            'query0': 'hubot gho create repo '
                            'query1': '/'
                            'numInputs': 2
                        }
                    }
                ]
            }
        }
        response.attachments = [card]
        res.send(response)

    # For creating a team with the returned name
    robot.respond /gho add to team/i, (res) ->
        response = initializeResponse(res)

        card = {
            'contentType': 'application/vnd.microsoft.card.adaptive'
            'content': {
                "type": "AdaptiveCard"
                "version": "1.0"
                "body": [
                    {
                        'type': 'TextBlock'
                        'text': 'hubot-github add to a team'
                        'speak': '<s>hubot-github add to a team</s>'
                        'weight': 'bolder'
                        'size': 'large'
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'Add members or repos?'
                    },
                    {
                        "type": "Input.ChoiceSet"
                        "id": "input0"
                        "style": "compact"
                        "value": "members"
                        "choices": [
                            {
                                "title": "Members"
                                "value": "members"
                            },
                            {
                                "title": "Repos"
                                "value": "repos"
                            }
                        ]
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'Enter a comma separated list of members or repos to add (Max 1024 characters)'
                        'wrap': true
                    },
                    {
                        'type': 'Input.Text'
                        'id': 'input1'
                        'speak': '<s>Enter a comma separated list of members or repos to add. Max 1024 characters'
                        'style': 'text'
                        'maxLength': 1024
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'What is the name of the team to add to? (Max 256 characters)'
                        'wrap': true
                    },
                    {
                        'type': 'Input.Text'
                        'id': 'input2'
                        'speak': '<s>What is the name of the team to add to? Max 256 characters</s>'
                        'style': 'text'
                        'maxLength': 256
                    }
                ],
                'actions': [
                    {
                        'type': 'Action.Submit'
                        'title': 'Submit'
                        'data': {
                            'query0': 'hubot gho add '
                            'query1': ' '
                            'query2': ' to team '
                            'numInputs': 3
                        }
                    }
                ]
            }
        }
        response.attachments = [card]
        res.send(response)

    # For creating a team with the returned name
    robot.respond /gho remove from team/i, (res) ->
        response = initializeResponse(res)

        card = {
            'contentType': 'application/vnd.microsoft.card.adaptive'
            'content': {
                "type": "AdaptiveCard"
                "version": "1.0"
                "body": [
                    {
                        'type': 'TextBlock'
                        'text': 'hubot-github remove from a team'
                        'speak': '<s>hubot-github remove from a team</s>'
                        'weight': 'bolder'
                        'size': 'large'
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'Remove members or repos?'
                        'speak': '<s>Remove members or repos?</s>'
                    },
                    {
                        "type": "Input.ChoiceSet"
                        "id": "input0"
                        "style": "compact"
                        "value": "members"
                        "choices": [
                            {
                                "title": "Members"
                                "value": "members"
                            },
                            {
                                "title": "Repos"
                                "value": "repos"
                            }
                        ]
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'Enter a comma separated list of members or repos to remove (Max 1024 characters)'
                        'wrap': true
                    },
                    {
                        'type': 'Input.Text'
                        'id': 'input1'
                        'speak': '<s>Enter a comma separated list of members or repos to remove. Max 1024 characters'
                        'style': 'text'
                        'maxLength': 1024
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'What is the name of the team to remove from? (Max 256 characters)'
                        'wrap': true
                    },
                    {
                        'type': 'Input.Text'
                        'id': 'input2'
                        'speak': '<s>What is the name of the team to remove from? Max 256 characters</s>'
                        'style': 'text'
                        'maxLength': 256
                    }
                ],
                'actions': [
                    {
                        'type': 'Action.Submit'
                        'title': 'Submit'
                        'data': {
                            'query0': 'hubot gho remove '
                            'query1': ' '
                            'query2': ' from team '
                            'numInputs': 3
                        }
                    }
                ]
            }
        }
        response.attachments = [card]
        res.send(response)

    # For creating a team with the inputted name
    robot.respond /gho delete what team/i, (res) ->
        response = initializeResponse(res)

        card = {
            'contentType': 'application/vnd.microsoft.card.adaptive'
            'content': {
                "type": "AdaptiveCard"
                "version": "1.0"
                "body": [
                    {
                        'type': 'TextBlock'
                        'text': 'hubot-github delete a team'
                        'speak': '<s>hubot-github delete a team</s>'
                        'weight': 'bolder'
                        'size': 'large'
                    },
                    {
                        'type': 'TextBlock'
                        'text': 'Delete which team? (Max 256 characters)'
                        
                    },
                    {
                        'type': 'Input.Text'
                        'id': 'input0'
                        'speak': '<s>Delete which team? Max 256 characters</s>'
                        'wrap': true
                        'style': 'text'
                        'maxLength': 256
                    }
                ],
                'actions': [
                    {
                        'type': 'Action.Submit'
                        'title': 'Submit'
                        'data': {
                            'query0': 'hubot gho delete team '
                            'numInputs': 1
                        }
                    }
                ]
            }
        }
        response.attachments = [card]
        res.send(response)

    robot.respond /list card me/i, (res) ->
        response = initializeResponse(res)
        card = {
            "contentType": "application/vnd.microsoft.teams.card.list",
            "content": {
                "title": "Card title",
                "items": [ {
                        "type": "file",
                        "id": "https://contoso.sharepoint.com/teams/new/Shared%20Documents/Report.xslx",
                        "title": "Report",
                        "subtitle": "teams > new > design",
                        "tap": {
                            "type": "imBack",
                            "value": "editOnline https://contoso.sharepoint.com/teams/new/Shared%20Documents/Report.xlsx"
                        }
                    },
                    {
                        "type": "resultItem",
                        "icon": "https://cdn2.iconfinder.com/data/icons/social-icons-33/128/Trello-128.png",
                        "title": "Trello title",
                        "subtitle": "A Trello subtitle",
                        "tap": {
                            "type": "openUrl",
                            "value": "http://trello.com"
                        }
                    },
                    {
                        "type": "section",
                        "title": "Manager"
                    },
                    {
                        "type": "person",
                        "id": "JohnDoe@contoso.com",
                        "title": "John Doe",
                        "subtitle": "Manager",
                        "tap": {
                            "type": "imBack",
                            "value": "whois JohnDoe@contoso.com"
                        }
                    }
                ],
                "buttons": [ {
                        "type": "imBack",
                        "title": "Select",
                        "value": "whois"
                    }
                ]
            }
        }

        response.attachments = [card]
        res.send(response)