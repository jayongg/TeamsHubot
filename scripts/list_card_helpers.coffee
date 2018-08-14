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
        # "icon": "https://cdn2.iconfinder.com/data/icons/social-icons-33/128/Trello-128.png",
        "title": "#{title}",
        "subtitle": "#{subtitle}",
        "tap": {
            "type": "invoke",
            "value": {
                'hubotMessage': "#{hubotMessage}"
            }
        }
    }
    return item


module.exports = {
    initializeListCard,
    createListResultItem
}