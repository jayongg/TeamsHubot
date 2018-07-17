class MockRobot
    constructor: ->
        @name = "robot"
        @logger =
            info: ->
            warn: ->
        @brain =
            userForId: -> {}
            users: -> []
            admins: -> 'Jay Ongg','Mel M'
            authorizedUsers -> ['Jay Ongg', 'Bob Blue', 'Mel M']
module.exports = MockRobot