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
# hubot admins - Lists the designated admins when using hubot with Microsoft Teams
# hubot authorized users - Lists the authorized users when using hubot with Microsoft Teams
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
    robot.respond /list hubot-github commands/i, (res) ->
        response = initializeResponse(res)

        heroCard = new BotBuilder.HeroCard()
        heroCard.title('hubot-github commands')
        buttons = []
        text = ""
        for command in @robot.commands
            if command.search(" gho ") != -1
                if text == ""
                    text = command
                else
                    text = "#{text}\n#{command}"
                parts = command.split(" - ")
                commandKeywords = parts[0].replace("hubot ", "")

                button = new BotBuilder.CardAction.imBack()
                button.title(escapeLessThan(commandKeywords))

                # Go to lookup table to get value (for multi dialogs)
                button.value(commandKeywords)
                tableValue = ButtonValueLUT[commandKeywords]
                console.log(tableValue)
                if tableValue != undefined
                    console.log("setting to table value")
                    button.value(tableValue)

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