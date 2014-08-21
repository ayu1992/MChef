$(document).ready ->
	$("#ToBuyBtn").click ->
		recipeIds = findRecipeIdsInDeck()
		if not recipeIds? or recipeIds.length is 0 then return
		$.ui.loadContent "main_ToBuy_List"
		getIngredientList(recipeIds)
		return
	$("#CookBtn").click ->
		recipeIds = findRecipeIdsInDeck()
		if not recipeIds? or recipeIds.length is 0 then return
		$.ui.loadContent "Cooking"
		getScheduledRecipe(recipeIds)
		return
	return

addThisRecipeToDeck = (id)->
	console.log "Add recipe ##{id} to deck"

	if window.recipesInDeck.length >= 6
		alert "抱歉，最多選 6 道菜做排程\n您現在選了 #{window.recipesInDeck.length} 道 "
		return

	### Push if not already in deck ###
	if window.recipesInDeck.lastIndexOf(id) is -1
		AddRecipeValue id # push this recipe into db
		checkRecipeInDB()

	window.deckChanged = true
	updateNavbarDeck()

	return

deleteThisRecipeFromDeck = (id)->
	### TODO ###
	console.log "delete #{id} from deck"

	### If not in deck, which is not possible but check anyway ###
	if (index = window.recipesInDeck.lastIndexOf(id)) is -1 then return
	window.recipesInDeck.splice index, 1
	console.log "deck: #{window.recipesInDeck}"

	window.deckChanged = true
	updateNavbarDeck()

	### delete from DB ###
	deleteRecipe(id)
	checkRecipeInDB()

	thisRecipeBtn = $("#Recipe#{id}")
	thisRecipeBtn.find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_add_btn chinese_font">加到調理台</div>'
	thisRecipeBtn = thisRecipeBtn.find(".recipe_btn")
	thisRecipeBtn.unbind 'click'
	thisRecipeBtn.click do(id)->
		-> #closure
			addThisRecipeToDeck(id)
			$("#main_Browse_Recipe").find("#Recipe#{id}").find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn chinese_font">已加入調理台</div>'
			return

	return

findRecipeIdsInDeck = ->
	recipeIds = []
	$('#main_Deck').find('.recipe_item').forEach (elem)->
		recipeIds.push elem.getAttribute 'data-recipe-id'
	console.log recipeIds
	return recipeIds

checkRecipeInDeck = (id)->
	#console.log "index for  #{id} is #{window.recipesInDeck.lastIndexOf(id)}"
	if window.recipesInDeck.lastIndexOf(id) is -1 then false else true

checkRecipeInDB = ->
	if not window.openDatabase
        alert 'Databases are not supported in this browser.'
        return

	sql = 'SELECT `recipeId` FROM `Recipes`'

	db.transaction (transaction)->
		transaction.executeSql sql, [], (transaction, result)->
			if result? and result.rows?
				### There is recipe in deck ###
				console.log "OK"
				window.recipesInDeck = []
				for x,i in result.rows
					row = result.rows.item(i)
					window.recipesExist = 1
					# console.log row.recipeId
					window.recipesInDeck.push row.recipeId
					updateNavbarDeck()
				return
			console.log "NOT OK"
			window.recipesExist = 0

		, errorHandler
		return
	, errorHandler, nullHandler
	return