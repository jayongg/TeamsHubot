# Testing hubot commands for adding/removing users and admins. Tests
# restriction of these commands to only admins.
# These tests are separate from the hubot-botframework adapter tests, so
# user restriction in the ability to send commands to hubot is not tested. 
Helper = require('hubot-test-helper')
chai = require 'chai'
expect = chai.expect

helper = new Helper('../scripts/teams_scripts.coffee')

describe 'Test authorization commands', ->
  beforeEach ->
    @room = helper.createRoom(source: 'msteams')
    auth = {
      "00000000-1111-2222-3333-555555555555": true
      "88888888-4444-4444-4444-121212121212": true
      "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee": false
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
        ['hubot', """00000000-1111-2222-3333-555555555555
        88888888-4444-4444-4444-121212121212"""]
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
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
        ['hubot', """00000000-1111-2222-3333-555555555555
        88888888-4444-4444-4444-121212121212
        aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"""]
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }
  
  # Test when authorization isn't enabled, authorized users command does nothing
  it 'when authorization isn\'t enabled, authorized users command does nothing', ->
    # Setup
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

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
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

    @room.user.say('bob', 'hubot authorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee', userParams).then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot authorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee']
      ]

  # Testing non-admin cannot authorize user
  it 'non-admin cannot authorize', ->
    # Setup
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

    # Action and Assert
    @room.user.say('bob', 'hubot authorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee', userParams).then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot authorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee']
        ['hubot', 'Only admins can authorize users']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }

  # Testing admin can authorize user
  it 'admin can authorize', ->
    # Setup
    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'

    # Action and Assert
    @room.user.say('Jell O', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj', userParams).then =>
        expect(@room.messages).to.eql [
            ['Jell O', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj']
            ['hubot', 'The user has been authorized']
        ]
        expect(@room.robot.brain.get("authorizedUsers")).to.eql {
          '00000000-1111-2222-3333-555555555555': true
          '88888888-4444-4444-4444-121212121212': true
          'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
          'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj': false
        }
        

  # Testing cannot authorize same user twice
  it 'cannot authorize same user twice', ->
    # Setup
    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'

    # Action and Assert
    @room.user.say('Jell O', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj', userParams).then =>
      userParams.aadObjectId = '00000000-1111-2222-3333-555555555555'

      @room.user.say('Mand M', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj', userParams).then =>
        expect(@room.messages).to.eql [
          ['Jell O', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj']
          ['hubot', 'The user has been authorized']
          ['Mand M', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj']
          ['hubot', 'The user is already authorized']
        ]
        expect(@room.robot.brain.get("authorizedUsers")).to.eql {
          '00000000-1111-2222-3333-555555555555': true
          '88888888-4444-4444-4444-121212121212': true
          'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
          'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj': false
        }

  ############################################
  # Test when authorization isn't enabled, unauthorize does nothing
  it 'when authorization isn\'t enabled, unauthorize command does nothing', ->
    # Setup
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    @room.user.say('Non Admin', 'hubot unauthorize 88888888-4444-4444-4444-121212121212', userParams).then =>
      expect(@room.messages).to.eql [
        ['Non Admin', 'hubot unauthorize 88888888-4444-4444-4444-121212121212']
      ]

  # Testing non-admin cannot unauthorize user
  it 'non-admin cannot unauthorize', ->
    # Setup
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

    # Action and Assert
    @room.user.say('Non Admin', 'hubot unauthorize 88888888-4444-4444-4444-121212121212', userParams).then =>
      expect(@room.messages).to.eql [
        ['Non Admin', 'hubot unauthorize 88888888-4444-4444-4444-121212121212']
        ['hubot', 'Only admins can unauthorize users']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }
  
  # Testing admin cannot unauthorize self
  it 'admin cannot unauthorize self', ->
    # Setup
    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'

    # Action and Assert
    @room.user.say('Mand M', 'hubot unauthorize 00000000-1111-2222-3333-555555555555', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize 00000000-1111-2222-3333-555555555555']
        ['hubot', 'You can\'t unauthorize yourself!']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }

  # Testing unauthorized user cannot be unauthorized
  it 'already unauthorized user cannot be unauthorized', ->
    # Setup
    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'

    # Action and Assert
    @room.user.say('Mand M', 'hubot unauthorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj']
        ['hubot', 'The user already isn\'t authorized']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }

  # Testing admin can unauthorize an authorized user
  it 'admin can unauthorize', ->
    # Setup
    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'

    # Action and Assert
    @room.user.say('Mand M', 'hubot unauthorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee']
        ['hubot', 'The user has been unauthorized']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
      }


  ############################################
  # Test when authorization isn't enabled, remove admins does nothing
  it 'when authorization isn\'t enabled, add admin command does nothing', ->
    # Setup
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin']
      ]

  # Test non-admin cannot add an admin
  it 'non-admin cannot add an admin', ->
    # Setup
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin']
        ['hubot', 'Only admins can add admins']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }

  # Test admin cannot add unauthorized user as admin
  it 'unauthorized user cannot be made an admin', ->
    # Setup
    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'

    # Action and Assert
    @room.user.say('Jell O', '@hubot make ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Jell O', '@hubot make ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj an admin']
        ['hubot', 'The user isn\'t authorized. Please authorize them first']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }

  # Test admin can add an authorized user as an admin
  it 'admin can make an authorized user an admin', ->
    # Setup
    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'

    # Action and Assert
    @room.user.say('Jell O', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Jell O', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin']
        ['hubot', 'The user is now an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': true
      }

  # Test admin cannot add someone who's already an admin
  it 'can\'t make someone an admin twice', ->
    # Setup
    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'

    # Action and Assert
    @room.user.say('Jell O', 'hubot make 00000000-1111-2222-3333-555555555555 an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Jell O', 'hubot make 00000000-1111-2222-3333-555555555555 an admin']
        ['hubot', 'The user is already an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }

  ############################################
  # Test when authorization isn't enabled, remove admins does nothing
  it 'when authorization isn\'t enabled, remove admin command does nothing', ->
    # Setup
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins']
      ]

  # Test non-admin can't remove an admin
  it 'non-admin cannot remove an admin', ->
    # Setup
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

    # Action and Assert
    @room.user.say('Bob Blue', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins']
        ['hubot', 'Only admins can remove admins']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }

  # Test admin cannot remove self as an admin
  it 'admin cannot remove self from admins', ->
    # Setup
    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'

    # Action and Assert
    @room.user.say('Mand M', 'hubot remove 88888888-4444-4444-4444-121212121212 from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot remove 88888888-4444-4444-4444-121212121212 from admins']
        ['hubot', 'You can\'t remove yourself as an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }

  # Test admin cannot remove someone as an admin who isn't an admin
  it 'admin cannot remove a non-admin from admins', ->
    # Setup
    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'

    # Action and Assert
    @room.user.say('Mand M', 'hubot remove aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot remove aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee from admins']
        ['hubot', 'The user already isn\'t an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': true
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }

  # Test admin can remove an admin
  it 'admin can remove another admin', ->
    # Setup
    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'

    # Action and Assert
    @room.user.say('Mand M', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins']
        ['hubot', 'The user has been removed as an admin']
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql {
        '00000000-1111-2222-3333-555555555555': false
        '88888888-4444-4444-4444-121212121212': true
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee': false
      }
  
  ############################################
  # Test when authorization isn't enabled, doesn't return anything
  it 'when authorization isn\'t enabled, doesn\'t return not authorized error', ->
    # Setup
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    @room.user.say('Mand M', 'hubot return unauthorized user error').then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot return unauthorized user error']
      ]

  # Test returns error with admins included
  it 'returns not authorized error with list of admins', ->
    # Setup

    # Action and Assert
    @room.user.say('Mand M', 'hubot return unauthorized user error').then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot return unauthorized user error']
        ['hubot', 'You are not authorized to send commands to hubot. Please 
        talk to your admins:<br/>- 00000000-1111-2222-3333-555555555555<br/>- 
        88888888-4444-4444-4444-121212121212<br/>to be authorized.']
      ]
    


  # Test when authorization isn't enabled, doesn't return anything
  it 'when authorization isn\'t enabled, doesn\'t return authorization not supported error', ->
    # Setup
    @room.robot.brain.remove("authorizedUsers")

    # Action and Assert
    @room.user.say('Mand M', 'hubot return source authorization not supported error').then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot return source authorization not supported error']
      ]

  # Test returns message that authorization isn't supported for that channel
  it 'returns authorization not supported for that channel error', ->
    # Setup

    # Action and Assert
    @room.user.say('Mand M', 'hubot return source authorization not supported error').then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot return source authorization not supported error']
        ['hubot', "Authorization isn't supported for this channel"]
      ]