# Testing hubot commands for adding/removing users and admins. Tests
# restriction of these commands to only admins.
# These tests are separate from the hubot-botframework adapter tests, so
# user restriction in the ability to send commands to hubot is not tested. 
Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect

helper = new Helper('../scripts/hubot-github_cards.coffee')

describe 'Test hubot-github Teams helper commands', ->
  beforeEach ->
    @room = helper.createRoom(source: 'msteams')
    # Populate robot.commands with the commands in hubot-github

  afterEach ->
    @room.destroy()
  
  ############################################
  it 'can access robot.commands', ->
    console.log(@room.robot)

  # Test list gho & hubot-github commands
  # Test hero card version
  # Test list card version
  # Test dropdown menu version
  # *** This will change when we decide on a final design for the menu
  # *** Will this even work because the commands pull from robot.commands


  # Test the generate input card commands returning the expected message (6 of them)
