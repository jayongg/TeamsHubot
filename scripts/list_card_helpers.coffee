# Helper functions for constructing Microsoft Teams List Cards


initializeListCard = () ->
    card = {
            "contentType": "application/vnd.microsoft.teams.card.list",
            "content": {
                "title": "Card title",
                "items": [],
                "buttons": []
            }
        }

addListItem = (listCard) ->
    


module.exports = {
    initializeListCard,
    createListItem
}