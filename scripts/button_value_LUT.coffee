# A class containing a lookup table used to control the command
# sent back to hubot when a user clicks a follow up button.
# These values include special commands used to gather information
# for hubot commands that require user input.

buttonValueLUT = {
    # hubot-github
    "gho-list": "hubot gho list which"
    "gho-create-team": "hubot gho create what team name"
}







module.exports = buttonValueLUT