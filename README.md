# hubot-msteams scripts

This repo contains scripts that extend the ability of the [Botframework adapter](https://github.com/Microsoft/BotFramework-Hubot). Commands for controlling authorization and for creating interactive menu command cards are included. For more detailed information on the Botframework adapter's authorization and cards, see [Botframework adapter](https://github.com/Microsoft/BotFramework-Hubot).

## Installation
To use these scripts, install hubot and the Botframework adapter. These scripts are designed to be used only with the Botframework adapter.
Until this is published as an npm package, download the repository and add the files in TeamsHubot/scripts/ to your hubot's scripts/ folder. 

## Dynamic Authorization in Teams
When enabling authorization in the Botframework adapter, these commands can be used to dynamically control the list of users authorized to send commands to hubot from Teams. The following commands are provided for use with authorization:

* Restricted to admins:
    * **hubot authorize \<UPN>** - Adds the user with the given UPN to the list of authorized users.
    * **hubot unauthorize \<UPN>** - Removes the user with the given UPN to the list of authorized users. If that user is an admin, they are also no longer an admin.
    * **hubot make \<UPN> an admin** - Makes the user with the given UPN an admin.
    * **hubot remove \<UPN> from admins** - Removes the user with the given UPN from the admins. The user is still an authorized user.

* Available to all authorized users:
    * **hubot admins** - Lists the UPNs of the admins.
    * **hubot authorized users** - Lists the UPNs of all authorized users.

In addition to typing the UPN, the user can also be @mentioned in Teams.

## Menu Cards
Menu cards contain all of the commands in a specific package of hubot scripts. To run a specific command from a menu card, click on the command. If the command needs user input, a card will be returned where the user can input the necessary inputs and submit the command.

Currently only menu cards for the [hubot-github](https://github.com/hydal/hubot-github) package is supported. Menu cards for other hubot script package can be added only if card interactions are already defined for the scripts in the Botframework adapter. 
When adding a new menu card command, use the `list (gho|hubot-github commands` command in `scripts/hubot-github_cards.coffee` as a template.

## Contributing
Add more information here once we learn more about Microsoft Open Source policies