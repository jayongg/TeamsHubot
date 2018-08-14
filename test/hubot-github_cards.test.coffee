# Description:
#   Testing hubot command for building a Microsoft Teams List Card containing
#   all of the commands in the hubot-github library. The card contains buttons
#   used to initiate execution of each of the commands when used with the
#   botframework-adapter


Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect

helper = new Helper('../scripts/hubot-github_cards.coffee')

describe 'Test hubot-github Teams commands', ->
    HUBOT_GITHUB_COMMANDS = [
        "hubot gho - returns a summary of your organization",
        "hubot gho list (team|repos|members) - returns a list of (members|teams|repos) in your org",
        "hubot gho list public repos - returns a list of your orgs public repos",
        "hubot gho create team <team name> - creates a team with the following name",
        "hubot gho create repo <repo name>/<public|private> - create a repo with the following name and optional status",
        "hubot gho add (members|repos) to team <team name> - adds a comma separated list of members or repos to the given team",
        "hubot gho remove (members|repos) from team <team name> - removes comma list of members or repos from the given team",
        "hubot gho delete team <team name> - deletes the given team from your org (doesn't delete the repos or members from your org)"
    ]

    expectedListCard = {
        "contentType": "application/vnd.microsoft.teams.card.list",
        "content": {
            "title": "hubot list gho commands",
            "items": [
                {
                    "type": "resultItem",
                    "title": "gho",
                    "subtitle": "returns a summary of your organization",
                    "tap": {
                        "type": "invoke",
                        "value": {
                            'hubotMessage': 'hubot gho'
                        }
                    }
                },
                {
                    "type": "resultItem",
                    "title": "gho list",
                    "subtitle": "returns a list of (members|teams|repos) in your org",
                    "tap": {
                        "type": "invoke",
                        "value": {
                            'hubotMessage': 'hubot gho list (team|repos|members)'
                        }
                    }
                },
                {
                    "type": "resultItem",
                    "title": "gho list public repos",
                    "subtitle": "returns a list of your orgs public repos",
                    "tap": {
                        "type": "invoke",
                        "value": {
                            'hubotMessage': 'hubot gho list public repos'
                        }
                    }
                },
                {
                    "type": "resultItem",
                    "title": "gho create team",
                    "subtitle": "creates a team with the following name",
                    "tap": {
                        "type": "invoke",
                        "value": {
                            'hubotMessage': 'hubot gho create team <team name>'
                        }
                    }
                },
                {
                    "type": "resultItem",
                    "title": "gho create repo",
                    "subtitle": "create a repo with the following name and optional status",
                    "tap": {
                        "type": "invoke",
                        "value": {
                            'hubotMessage': 'hubot gho create repo <repo name>/<public|private>'
                        }
                    }
                },
                {
                    "type": "resultItem",
                    "title": "gho add",
                    "subtitle": "adds a comma separated list of members or repos to the given team",
                    "tap": {
                        "type": "invoke",
                        "value": {
                            'hubotMessage': 'hubot gho add (members|repos) to team <team name>'
                        }
                    }
                },
                {
                    "type": "resultItem",
                    "title": "gho remove",
                    "subtitle": "removes comma list of members or repos from the given team",
                    "tap": {
                        "type": "invoke",
                        "value": {
                            'hubotMessage': 'hubot gho remove (members|repos) from team <team name>'
                        }
                    }
                },
                {
                    "type": "resultItem",
                    "title": "gho delete team",
                    "subtitle": "deletes the given team from your org (doesn't delete the repos or members from your org)",
                    "tap": {
                        "type": "invoke",
                        "value": {
                            'hubotMessage': 'hubot gho delete team <team name>'
                        }
                    }
                }
            ]
        }
    }

    expectedResponse = {
        type: 'message'
        address: 'a-botframework-message-address-object'
        attachments: [
            expectedListCard
        ]
    }

    userParams = 
            activity:
                address: 'a-botframework-message-address-object'
    
    beforeEach ->
        @room = helper.createRoom(source: 'msteams')

        # Populate robot.commands with the commands in hubot-github
        for command in HUBOT_GITHUB_COMMANDS
            @room.robot.commands.push(command)

    afterEach ->
        @room.destroy()

    it 'list gho commands should return a proper response with the correct card', ->
        # Setup

        # Action and Assert
        @room.user.say('Bob Blue', 'hubot list gho commands', userParams).then =>
            expect(@room.messages).to.eql [
                ['Bob Blue', 'hubot list gho commands']
                ['hubot', expectedResponse]
            ]   

    it 'list hubot-github commands should return a proper response with the correct card', ->
        # Setup
        expectedListCard.content.title = 'hubot list hubot-github commands'

        # Action and Assert
        @room.user.say('Bob Blue', 'hubot list hubot-github commands', userParams).then =>
            expect(@room.messages).to.eql [
                ['Bob Blue', 'hubot list hubot-github commands']
                ['hubot', expectedResponse]
            ]