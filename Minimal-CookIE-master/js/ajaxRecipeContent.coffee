getRecipeContent = (recipeId)->
	$.ajax(
		type: 'GET'
		url: 'http://54.178.135.71:8080/CookIEServer/recipedigest'
		#dataType: 'jsonp'
		#crossDomain: true
		#jsonp: false
		dataType: 'application/json'
		data:
			'recipe_id': recipeId
		timeout: 10000
		success: (data)->
			data = JSON.parse(data)
			console.log "[SUCCESS]fetch recipe #"+recipeId
			console.log data

			scope = $("#RecipeContent")
			setTimeout(loadRecipeContent(scope, data), 1000)
			return #avoid implicit rv
		error: (resp)->
			console.log "[ERROR]fetch recipe #"+recipeId
			console.log resp
			if resp.status is 0
				alert "Server Error. Try again later."
			else
				alert "Connection Error: #{resp.status}"
			$.ui.loadContent "main_Browse_Recipe"
			return #avoid implicit rv
	)
	return #avoid implicit rv

loadRecipeContent = (scope, recipe)->
	$.ui.setTitle recipe.recipeName
	scope.find("#Results").hide()
	scope.find("#Loading").show()

	# Info
	scope.find("#RecipeImg").attr("src", recipe.image)
	scope.find("#RecipeImg").attr("data-recipe-id", recipe.recipeId)
	scope.find("#RecipeDescription").text recipe.description
	scope.find("#RecipeUploadInfo").text "Uploaded by: "+recipe.authorName+", "+(new Date(recipe.date))
	#scope.find("#RecipeTime").text "Time needed: "+recipe.timeNeeded
	if recipe.share is 0 then scope.find("#RecipeShare").html ""
	else scope.find("#RecipeShare").html "（#{recipe.share} 人份）"

	# Ingredients
	len = recipe.ingredientGroup[0].length
	len = Math.ceil len/2

	ingListLeft = scope.find("#RecipeIngredientListLeft")[0]
	ingListLeft.firstElementChild.innerHTML = "" #remove previous content
	ingListLeft.lastElementChild.innerHTML = ""
	ingListRight = scope.find("#RecipeIngredientListRight")[0]
	ingListRight.firstElementChild.innerHTML = ""
	ingListRight.lastElementChild.innerHTML = ""
	for group, i in recipe.ingredientGroup
		html = ''
		for ingredient, j in group.ingredients
			console.log ingredient.ingredientName
			if (i+j)%2 # odd
				# append ing. name
				html = "<li>#{ingredient.ingredientName}</li>"
				$(ingListRight.firstElementChild).append html
				# append ing. amount
				html = "<li>#{ingredient.amount}#{ingredient.unitName}</li>"
				$(ingListRight.lastElementChild).append html
			else # even
				# append ing. name
				html = "<li>#{ingredient.ingredientName}</li>"
				$(ingListLeft.firstElementChild).append html
				# append ing. amount
				html = "<li>#{ingredient.amount}#{ingredient.unitName}</li>"
				$(ingListLeft.lastElementChild).append html
	# Steps
	stepList = scope.find("#RecipeSteps")
	stepList.html "" #remove previous content
	for step, i in recipe.stepDigests
		html = '<li>'+(i+1)+'. '+step.step+'</li>'
		stepList.append html
	stepList.append '<br />'

	# Comments
		# do something
	# Messages
		# do something
	#Photos
	imgList = scope.find("#RecipePhotos")
		# do something

	id = recipe.recipeId
	if window.recipesInDeck.lastIndexOf(id) isnt -1
		### recipe already in the deck ###
		scope.find("#RecipeContentBtn")[0].outerHTML = '<div id="RecipeContentBtn" class="button" style="width:100%;background-color:#D8D8D8;opacity:.8;height:8%;border-radius:0;border:0;">已加入調理台</div>'
		thisRecipeBtn = scope.find "#RecipeContentBtn"
		thisRecipeBtn.click ->
			$.ui.loadContent 'main_Deck'
			undefined
	else
		scope.find("#RecipeContentBtn")[0].outerHTML = '<div id="RecipeContentBtn" class="button" style="width:100%;background:hsl(204.1,35%,53.1%);opacity:.8;height:8%;border-radius:0;border:0;">加到調理台</div>'
		thisRecipeBtn = scope.find "#RecipeContentBtn"
		thisRecipeBtn.click do(id)->
			-> # closure
				addThisRecipeToDeck(id)
				
				if window.recipesInDeck.length >= 6 then return
				thisRecipeBtn[0].outerHTML = '<div id="RecipeContentBtn" class="button" style="width:100%;background-color:#D8D8D8;height:8%;border-radius:0;border:0;">已加入調理台</div>'
				$("#main_Browse_Recipe").find("#Recipe#{id}").find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn" >已加入調理台</div>'
				undefined

	scope.find("#Loading").hide()
	scope.find("#Results").show()

	return #avoid implicit rv