# Helper functions for constructing Microsoft Teams List Cards


initializeListCard = (title) ->
    card = {
            "contentType": "application/vnd.microsoft.teams.card.list",
            "content": {
                "title": "#{title}"
            }
        }
    return card

createListResultItem = (title, subtitle, hubotMessage) ->
    item = {
        "type": "resultItem",
        "icon": "https://github.com/jayongg/TeamsHubot/blob/icons/images/GitHub-Mark-64px.png",
        "title": "#{title}",
        "subtitle": "#{subtitle}",
        "tap": {
            "type": "invoke",
            "value": {
                'hubotMessage': "#{hubotMessage}"
            }
        }
    }
    console.log(item.icon)
    return item


module.exports = {
    initializeListCard,
    createListResultItem
}