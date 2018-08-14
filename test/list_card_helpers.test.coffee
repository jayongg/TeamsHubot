# Description:
#   Testing helper commands for constructing Microsoft Teams List Cards.


chai = require 'chai'
expect = chai.expect
ListCardHelpers = require('../scripts/list_card_helpers')

describe 'Test MS Teams List Card helper functions', ->
    it 'should create basic card structure', ->
        # Setup
        expected = {
            "contentType": "application/vnd.microsoft.teams.card.list",
            "content": {
                "title": "a-title"
            }
        }
        
        # Action
        result = null
        expect(() ->
            result = ListCardHelpers.initializeListCard('a-title')
        ).to.not.throw()

        # Assert
        expect(result).to.be.a('Object')
        expect(result).to.eql expected

    it 'should create proper result item', ->
        # Setup
        expected = {
            "type": "resultItem",
            "title": "another-title",
            "subtitle": "some-description",
            "tap": {
                "type": "invoke",
                "value": {
                    'hubotMessage': 'hubot a-hubot-message'
                }
            }
        }
        
        # Action
        result = null
        expect(() ->
            result = ListCardHelpers.createListResultItem("another-title", \
                                        "some-description", "hubot a-hubot-message")
        ).to.not.throw()

        # Assert
        expect(result).to.be.a('Object')
        expect(result).to.eql expected