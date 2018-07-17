# Testing hubot commands for adding/removing users and admins. Tests
# restriction of these commands to only admins.
# These tests are separate from the hubot-botframework adapter tests, so
# user restriction in the ability to send commands to hubot is not tested.
Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../scripts/example.coffee')


describe 'example script', ->
  beforeEach ->
    @room = helper.createRoom(source: 'msteams')
    # process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    # @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    # process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    # @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

  afterEach ->
    @room.destroy()
  
  ############################################
  # Testing listing admins
  it 'can list admins', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    @room.user.say('Bob Blue', 'hubot admins').then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot admins']
        ['hubot', """00000000-1111-2222-3333-555555555555
        88888888-4444-4444-4444-121212121212"""]
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Testing when auth not set, does nothing
  it 'when auth not set, admins command does nothing', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = undefined
    @room.user.say('Bob Blue', 'hubot admins').then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot admins']
      ]

  ############################################
  # Testing listing authorized users
  it 'can list authorized users', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    @room.user.say('Bob Blue', '@hubot authorized users').then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', '@hubot authorized users']
        ['hubot', """00000000-1111-2222-3333-555555555555
        88888888-4444-4444-4444-121212121212
        aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"""]
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]
  
  # Test when auth not set, authorized users command does nothing
  it 'when auth not set, authorized users command does nothing', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = undefined
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

    @room.user.say('Bob Blue', '@hubot authorized users').then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', '@hubot authorized users']
      ]

  ############################################
  # Test when auth not set, authorize does nothing
  it 'when auth not set, authorize command does nothing', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = undefined
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

    @room.user.say('bob', 'hubot authorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee', userParams).then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot authorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee']
      ]

  # Testing non-admin cannot authorize user
  it 'non-admin cannot authorize', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

    @room.user.say('bob', 'hubot authorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee', userParams).then =>
      expect(@room.messages).to.eql [
        ['bob', 'hubot authorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee']
        ['hubot', 'Only admins can authorize users']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Testing admin can authorize user
  it 'admin can authorize', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'

    @room.user.say('Jell O', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj', userParams).then =>
        expect(@room.robot.brain.get("admins")).to.eql [
            '00000000-1111-2222-3333-555555555555'
            '88888888-4444-4444-4444-121212121212'
        ]
        expect(@room.robot.brain.get("authorizedUsers")).to.eql [
            '00000000-1111-2222-3333-555555555555'
            '88888888-4444-4444-4444-121212121212'
            'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
            'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj'
        ]
        expect(@room.messages).to.eql [
            ['Jell O', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj']
            ['hubot', 'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj has been authorized']
        ]
        

  # Testing cannot authorize same user twice
  it 'cannot authorize same user twice', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'

    @room.user.say('Jell O', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj', userParams).then =>
      userParams.aadObjectId = '00000000-1111-2222-3333-555555555555'

      @room.user.say('Mand M', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj', userParams).then =>
        expect(@room.messages).to.eql [
          ['Jell O', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj']
          ['hubot', 'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj has been authorized']
          ['Mand M', 'hubot authorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj']
          ['hubot', 'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj is already authorized']
        ]
        expect(@room.robot.brain.get("admins")).to.eql [
          '00000000-1111-2222-3333-555555555555'
          '88888888-4444-4444-4444-121212121212'
        ]
        expect(@room.robot.brain.get("authorizedUsers")).to.eql [
          '00000000-1111-2222-3333-555555555555'
          '88888888-4444-4444-4444-121212121212'
          'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
          'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj'
        ]

  ############################################
  # Test when auth not set, unauthorize does nothing
  it 'when auth not set, unauthorize command does nothing', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = undefined
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    @room.user.say('Non Admin', 'hubot unauthorize 88888888-4444-4444-4444-121212121212', userParams).then =>
      expect(@room.messages).to.eql [
        ['Non Admin', 'hubot unauthorize 88888888-4444-4444-4444-121212121212']
      ]

  # Testing non-admin cannot unauthorize user
  it 'non-admin cannot unauthorize', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'

    @room.user.say('Non Admin', 'hubot unauthorize 88888888-4444-4444-4444-121212121212', userParams).then =>
      expect(@room.messages).to.eql [
        ['Non Admin', 'hubot unauthorize 88888888-4444-4444-4444-121212121212']
        ['hubot', 'Only admins can unauthorize users']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]
  
  # Testing admin cannot unauthorize self
  it 'admin cannot unauthorize self', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'

    @room.user.say('Mand M', 'hubot unauthorize 00000000-1111-2222-3333-555555555555', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize 00000000-1111-2222-3333-555555555555']
        ['hubot', 'You can\'t unauthorize yourself!']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Testing unauthorized user cannot be unauthorized
  it 'already unauthorized user cannot be unauthorized', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'

    @room.user.say('Mand M', 'hubot unauthorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj']
        ['hubot', 'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj already isn\'t authorized']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Testing admin can unauthorize an authorized user
  it 'admin can unauthorize', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'

    @room.user.say('Mand M', 'hubot unauthorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee']
        ['hubot', 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee has been unauthorized']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]

  # Testing when admin unauthorizes another admin, it removes them from
  #  admins too
  it 'admin can unauthorize an admin', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'
    @room.user.say('Mand M', 'hubot unauthorize 00000000-1111-2222-3333-555555555555', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot unauthorize 00000000-1111-2222-3333-555555555555']
        ['hubot', '00000000-1111-2222-3333-555555555555 has been unauthorized']
        ['hubot', '00000000-1111-2222-3333-555555555555 was also removed as an admin']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  ############################################
  # Test when auth not set, remove admins does nothing
  it 'when auth not set, add admin command does nothing', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = undefined
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    @room.user.say('Bob Blue', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin']
      ]

  # Test non-admin cannot add an admin
  it 'non-admin cannot add an admin', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    @room.user.say('Bob Blue', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin']
        ['hubot', 'Only admins can add admins']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Test admin cannot add unauthorized user as admin
  it 'unauthorized user cannot be made an admin', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'
    @room.user.say('Jell O', '@hubot make ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Jell O', '@hubot make ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj an admin']
        ['hubot', 'ffffffff-gggg-hhhh-iiii-jjjjjjjjjjjj isn\'t authorized. Please authorize them first']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Test admin can add an authorized user as an admin
  it 'admin can make an authorized user an admin', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '00000000-1111-2222-3333-555555555555'
    @room.user.say('Jell O', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Jell O', 'hubot make aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee an admin']
        ['hubot', 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee is now an admin']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Test admin cannot add someone who's already an admin
  it 'can\'t make someone an admin twice', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'
    @room.user.say('Jell O', 'hubot make 00000000-1111-2222-3333-555555555555 an admin', userParams).then =>
      expect(@room.messages).to.eql [
        ['Jell O', 'hubot make 00000000-1111-2222-3333-555555555555 an admin']
        ['hubot', '00000000-1111-2222-3333-555555555555 is already an admin']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  ############################################
  # Test when auth not set, remove admins does nothing
  it 'when auth not set, remove admin command does nothing', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = undefined
    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    @room.user.say('Bob Blue', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins']
      ]

  it 'non-admin cannot remove an admin', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
    @room.user.say('Bob Blue', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Bob Blue', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins']
        ['hubot', 'Only admins can remove admins']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Test admin cannot remove self as an admin
  it 'admin cannot remove self from admins', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'
    @room.user.say('Mand M', 'hubot remove 88888888-4444-4444-4444-121212121212 from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot remove 88888888-4444-4444-4444-121212121212 from admins']
        ['hubot', 'You can\'t remove yourself as an admin']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Test admin cannot remove someone as an admin who isn't an admin
  it 'admin cannot remove a non-admin from admins', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'
    @room.user.say('Mand M', 'hubot remove aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot remove aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee from admins']
        ['hubot', 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee already isn\'t an admin']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

  # Test admin can remove an admin
  it 'admin can remove another admin', ->
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212,aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    @room.robot.brain.set("authorizedUsers", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))
    process.env.HUBOT_TEAMS_INITIAL_ADMINS = "00000000-1111-2222-3333-555555555555,88888888-4444-4444-4444-121212121212"
    @room.robot.brain.set("admins", process.env.HUBOT_TEAMS_INITIAL_ADMINS.split(","))

    userParams = 
        aadObjectId: '88888888-4444-4444-4444-121212121212'
    @room.user.say('Mand M', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins', userParams).then =>
      expect(@room.messages).to.eql [
        ['Mand M', 'hubot remove 00000000-1111-2222-3333-555555555555 from admins']
        ['hubot', '00000000-1111-2222-3333-555555555555 has been removed as an admin']
      ]
      expect(@room.robot.brain.get("admins")).to.eql [
        '88888888-4444-4444-4444-121212121212'
      ]
      expect(@room.robot.brain.get("authorizedUsers")).to.eql [
        '00000000-1111-2222-3333-555555555555'
        '88888888-4444-4444-4444-121212121212'
        'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'
      ]

#   it 'won\'t open the pod bay doors', ->
#     @room.user.say('bob', '@hubot open the pod bay doors').then =>
#       expect(@room.messages).to.eql [
#         ['bob', '@hubot open the pod bay doors']
#         ['hubot', '@bob I\'m afraid I can\'t let you do that.']
#       ]

#   it 'will open the dutch doors', ->
#     @room.user.say('bob', '@hubot open the dutch doors').then =>
#       expect(@room.messages).to.eql [
#         ['bob', '@hubot open the dutch doors']
#         ['hubot', '@bob Opening dutch doors']
#       ]