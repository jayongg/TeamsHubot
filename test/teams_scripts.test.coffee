# Description:
#   Testing hubot commands for adding/removing users and admins. Tests
#   restriction of these commands to only admins.
#   These tests are separate from the hubot-botframework adapter tests, so
#   restriction in the ability to send commands to hubot in general from
#   Teams is not tested.


Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect

helper = new Helper('../scripts/teams_scripts.coffee')

describe 'Test authorization commands', ->
  beforeEach ->
    @room = helper.createRoom(source: 'msteams')
    auth = {
      "user-1.upn@email.co.blah": true
      "user2_email_@some.site": true
      "user_3@website.net": false
    }
    @room.robot.brain.set("authorizedUsers", auth)

  afterEach ->
    @room.destroy()
  
  ############################################
  # Testing listing admins
  it 'can list admins', ->
    # Setup

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot admins').then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot admins']
        ['hubot', """user-1.upn@email.co.blah
        user2_email_@some.site"""]
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  # Testing when authorization isn't enabled, admins command does nothing
  it 'when authorization isn\'t enabled, admins command does nothing', ->
    # Setup
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot admins').then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot admins']
      ]

  ############################################
  # Testing listing authorized users
  it 'can list authorized users', ->
    # Setup

    # Action and Assert
    @room.user.say('Bob Blue', '@hubot authorized users').then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', '@hubot authorized users']
        ['hubot', """user-1.upn@email.co.blah
        user2_email_@some.site
        user_3@website.net"""]
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }
  
  # Test when authorization isn't enabled, authorized users command does nothing
  it 'when authorization isn\'t enabled, authorized users command does nothing', ->
    # Setup
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    userParams = 
        userPrincipalName: 'user_3@website.net'

    @room.user.say('Bob Blue', '@hubot authorized users').then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', '@hubot authorized users']
      ]

  ############################################
  # Test when authorization isn't enabled, authorize does nothing
  it 'when authorization isn\'t enabled, authorize command does nothing', ->
    # Setup
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    userParams = 
        userPrincipalName: 'user_3@website.net'

    @room.user.say('bob', 'hubot authorize user_3@website.net', userParams).then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot authorize user_3@website.net']
      ]

  # Testing non-admin cannot authorize user
  it 'non-admin cannot authorize', ->
    # Setup
    userParams = 
        userPrincipalName: 'user_3@website.net'

    # Action and Assert
    @room.user.say('bob', 'hubot authorize user_3@website.net', userParams).then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot authorize user_3@website.net']
        ['hubot', 'Only admins can authorize users']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  # Testing admin can authorize user
  it 'admin can authorize', ->
    # Setup
    userParams = 
        userPrincipalName: 'user-1.upn@email.co.blah'

    # Action and Assert
    @room.user.say('Jell O', 'hubot authorize another_user4@myweb.site', userParams).then =>
        expect(@room.messages).to.eql [
            ['Jell O', 'hubot authorize another_user4@myweb.site']
            ['hubot', 'The user has been authorized']
        ]
        expect(@room.robot.brain.get("authorizedUsers")).to.eql {
          'user-1.upn@email.co.blah': true
          'user2_email_@some.site': true
          'user_3@website.net': false
          'another_user4@myweb.site': false
        }
        

  # Testing cannot authorize same user twice
  it 'cannot authorize same user twice', ->
    # Setup
    userParams = 
        userPrincipalName: 'user2_email_@some.site'

    # Action and Assert
    @room.user.say('Jell O', 'hubot authorize another_user4@myweb.site', userParams).then =>
      userParams.userPrincipalName = 'user-1.upn@email.co.blah'

      @room.user.say('Mand M', 'hubot authorize another_user4@myweb.site', userParams).then =>
        expect(@room.messages).to.eql [
          ['Jell O', 'hubot authorize another_user4@myweb.site']
          ['hubot', 'The user has been authorized']
          ['Mand M', 'hubot authorize another_user4@myweb.site']
          ['hubot', 'The user is already authorized']
        ]
        expect(@room.robot.brain.get("authorizedUsers")).to.eql {
          'user-1.upn@email.co.blah': true
          'user2_email_@some.site': true
          'user_3@website.net': false
          'another_user4@myweb.site': false
        }

  ############################################
  # Test when authorization isn't enabled, unauthorize does nothing
  it 'when authorization isn\'t enabled, unauthorize command does nothing', ->
    # Setup
    userParams = 
        userPrincipalName: 'user_3@website.net'
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    @room.user.say('Non Admin', 'hubot unauthorize user2_email_@some.site', userParams).then =>
      expect(@room.messages).to.eql [
        ['Non Admin', 'hubot unauthorize user2_email_@some.site']
      ]

  # Testing non-admin cannot unauthorize user
  it 'non-admin cannot unauthorize', ->
    # Setup
    userParams = 
        userPrincipalName: 'user_3@website.net'

    # Action and Assert
    @room.user.say('Non Admin', 'hubot unauthorize user2_email_@some.site', userParams).then =>
      expect(@room.messages).to.eql [
        ['Non Admin', 'hubot unauthorize user2_email_@some.site']
        ['hubot', 'Only admins can unauthorize users']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }
  
  # Testing admin cannot unauthorize self
  it 'admin cannot unauthorize self', ->
    # Setup
    userParams = 
        userPrincipalName: 'user-1.upn@email.co.blah'

    # Action and Assert
    @room.user.say('Mand M', 'hubot unauthorize user-1.upn@email.co.blah', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize user-1.upn@email.co.blah']
        ['hubot', 'You can\'t unauthorize yourself!']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  # Testing unauthorized user cannot be unauthorized
  it 'already unauthorized user cannot be unauthorized', ->
    # Setup
    userParams = 
        userPrincipalName: 'user2_email_@some.site'

    # Action and Assert
    @room.user.say('Mand M', 'hubot unauthorize another_user4@myweb.site', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize another_user4@myweb.site']
        ['hubot', 'The user already isn\'t authorized']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  # Testing admin can unauthorize an authorized user
  it 'admin can unauthorize', ->
    # Setup
    userParams = 
        userPrincipalName: 'user-1.upn@email.co.blah'

    # Action and Assert
    @room.user.say('Mand M', 'hubot unauthorize user_3@website.net', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize user_3@website.net']
        ['hubot', 'The user has been unauthorized']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
      }


  ############################################
  # Test when authorization isn't enabled, remove admins does nothing
  it 'when authorization isn\'t enabled, add admin command does nothing', ->
    # Setup
    userParams = 
        userPrincipalName: 'user_3@website.net'
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot make user_3@website.net an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot make user_3@website.net an admin']
      ]

  # Test non-admin cannot add an admin
  it 'non-admin cannot add an admin', ->
    # Setup
    userParams = 
        userPrincipalName: 'user_3@website.net'

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot make user_3@website.net an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot make user_3@website.net an admin']
        ['hubot', 'Only admins can add admins']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  # Test admin cannot add unauthorized user as admin
  it 'unauthorized user cannot be made an admin', ->
    # Setup
    userParams = 
        userPrincipalName: 'user-1.upn@email.co.blah'

    # Action and Assert
    @room.user.say('Jell O', '@hubot make another_user4@myweb.site an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Jell O', '@hubot make another_user4@myweb.site an admin']
        ['hubot', 'The user isn\'t authorized. Please authorize them first']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  # Test admin can add an authorized user as an admin
  it 'admin can make an authorized user an admin', ->
    # Setup
    userParams = 
        userPrincipalName: 'user-1.upn@email.co.blah'

    # Action and Assert
    @room.user.say('Jell O', 'hubot make user_3@website.net an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Jell O', 'hubot make user_3@website.net an admin']
        ['hubot', 'The user is now an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': true
      }

  # Test admin cannot add someone who's already an admin
  it 'can\'t make someone an admin twice', ->
    # Setup
    userParams = 
        userPrincipalName: 'user2_email_@some.site'

    # Action and Assert
    @room.user.say('Jell O', 'hubot make user-1.upn@email.co.blah an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Jell O', 'hubot make user-1.upn@email.co.blah an admin']
        ['hubot', 'The user is already an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  ############################################
  # Test when authorization isn't enabled, remove admins does nothing
  it 'when authorization isn\'t enabled, remove admin command does nothing', ->
    # Setup
    userParams = 
        userPrincipalName: 'user_3@website.net'
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot remove user-1.upn@email.co.blah from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot remove user-1.upn@email.co.blah from admins']
      ]

  # Test non-admin can't remove an admin
  it 'non-admin cannot remove an admin', ->
    # Setup
    userParams = 
        userPrincipalName: 'user_3@website.net'

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot remove user-1.upn@email.co.blah from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot remove user-1.upn@email.co.blah from admins']
        ['hubot', 'Only admins can remove admins']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  # Test admin cannot remove self as an admin
  it 'admin cannot remove self from admins', ->
    # Setup
    userParams = 
        userPrincipalName: 'user2_email_@some.site'

    # Action and Assert
    @room.user.say('Mand M', 'hubot remove user2_email_@some.site from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot remove user2_email_@some.site from admins']
        ['hubot', 'You can\'t remove yourself as an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  # Test admin cannot remove someone as an admin who isn't an admin
  it 'admin cannot remove a non-admin from admins', ->
    # Setup
    userParams = 
        userPrincipalName: 'user2_email_@some.site'

    # Action and Assert
    @room.user.say('Mand M', 'hubot remove user_3@website.net from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot remove user_3@website.net from admins']
        ['hubot', 'The user already isn\'t an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': true
        'user2_email_@some.site': true
        'user_3@website.net': false
      }

  # Test admin can remove an admin
  it 'admin can remove another admin', ->
    # Setup
    userParams = 
        userPrincipalName: 'user2_email_@some.site'

    # Action and Assert
    @room.user.say('Mand M', 'hubot remove user-1.upn@email.co.blah from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot remove user-1.upn@email.co.blah from admins']
        ['hubot', 'The user has been removed as an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        'user-1.upn@email.co.blah': false
        'user2_email_@some.site': true
        'user_3@website.net': false
      }