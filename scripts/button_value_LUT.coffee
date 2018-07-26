# A class containing a lookup table used to control the command
# sent back to hubot when a user clicks a follow up button.
# These values include special commands used to gather information
# for hubot commands that require user input.

ButtonValueLUT = {
    # hubot-github
    "gho list (teams|repos|members)": "gho list which"
    "gho create team <team name>": "gho create what team name"
    "gho create repo <repo name>/<private|public>": "gho create what repo name and privacy"
    "gho add (members|repos) <members|repos> to team <team name>": "gho add to team"
    "gho remove (repos|members) <members|repos> from team <team name>": "gho remove from team"
    "gho delete team <team name>": "gho delete what team"
}







module.exports = ButtonValueLUT