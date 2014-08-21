$(document).ready ->
	initSidebarIcons();

	$("#ToBuyListCookBtn").click ->
		getScheduledRecipe window.recipesInDeck
		$.ui.loadContent 'Cooking'
		return

	$("#DoneBtn").click ->
		db.transaction (transaction)->
			sql = 'DELETE FROM `Recipes`'
			transaction.executeSql sql, [], successCallBack, errorHandler
			sql = 'DELETE FROM `MenuIngredients`'
			transaction.executeSql sql, [], ->
					$("#ToBuyListCookBtn").addClass 'hidden'
					$("#EmptyNotify").removeClass 'hidden'
					window.recipesInDeck = []
					loadDeck()
					loadRecipes()
				, errorHandler

			return
		, errorHandler, nullHandler

		$("#EmptyNotify").addClass 'hidden'
		$("#ToBuyListCookBtn").removeClass 'hidden'
		$("#list").html ""

		# reset variables used in cooking
		window.cookingData = null
		window.currentStepNum = 0
		window.currentStep = null
		window.currentTime = 0
		window.waitingStepQueue = []
		window.stepsTimeUsed = []
		window.cookingStartTime = null
		return

initSidebarIcons = ->
	$(".icon.close").click ->
		ans = confirm "這會清除您調理台與購買清單中的所有資料\n繼續？"
		if ans is no then return

		db.transaction (transaction)->
			sql = 'DELETE FROM `Recipes`'
			transaction.executeSql sql, [], successCallBack, errorHandler
			sql = 'DELETE FROM `MenuIngredients`'
			transaction.executeSql sql, [], ->
					$("#ToBuyListCookBtn").addClass 'hidden'
					$("#EmptyNotify").removeClass 'hidden'
					window.recipesInDeck = []
					loadDeck()
					loadRecipes()
				, errorHandler
			return
		, errorHandler, nullHandler

		$("#EmptyNotify").addClass 'hidden'
		$("#ToBuyListCookBtn").removeClass 'hidden'
		$("#list").html ""

		# reset variables used in cooking
		window.cookingData = null
		window.currentStepNum = 0
		window.currentStep = null
		window.currentTime = 0
		window.waitingStepQueue = []
		window.stepsTimeUsed = []
		window.cookingStartTime = null

		return
		$.ui.loadContent "main_Browse_Recipe"
	return

sendFeedback = ->
	name = $("#feedbackName").val()
	mail = $("#feedbackMail").val()
	type = 
		switch($("#feedbackType").val())
			when '食譜請求' then 'recipe'
			when '臭蟲回報' then 'bug'
			when '意見' then 'feedback'
	msg = $("#feedbackContent").val()

	url = ""

	$.ajax
		type: 'POST'
		url: url
		dataType: 'application/json'
		data:
			'name': name
			'mail': mail
			'type': type
			'message': msg
		timeout: 10000
		success: (data)->
			data = JSON.parse(data)
			console.log "[SUCCESS] send feedback"
			### TODO Insert token into SQL ###

			alert "Thank you for your support!"
			return
		error: (resp)->
			console.log "[ERROR] send feedback"
			if resp.status is 0 then alert "Server Error. Try again later."
			else alert "Connection error: #{resp.status}"

			return
	return



addInfiniteScroll = (scope, delay, callback)->
	console.log "add infinite-scroll to scope:" + scope[0].id
	scrollerList = scope.scroller()
	scrollerList.clearInfinite()
	scrollerList.addInfinite()
	$.bind(scrollerList, 'infinite-scroll', ->
		console.log scope[0].id+" infinite-scroll"
		scope.find("#infinite").text "Loading more..."
		scrollerList.addInfinite()

		clearTimeout window.lastId
		window.lastId = setTimeout(->
			callback()
		, delay)
	)
	return #avoid implicit return values

recipeAjaxd = 0
loadRecipes = ->
	console.log "load recipes"
	scope = $('#main_Browse_Recipe')
	scope.find('#Results').html ""
	scope.find("#infinite").text "Reloading..."
	recipeAjaxd = 0

	getRecipes(recipeAjaxd)
	updateNavbarDeck()
	return

allCatAjaxd = 0
loadCateogries = ->
	console.log "load categories"
	scope = $("#main_Browse_Category")
	scope.find("#Results").html ""
	scope.find("#infinite").text "Loading..."
	allCatAjaxd = 0

	getAllCategory(allCatAjaxd)
	
	return

loadDeck = ->
	console.log "loading deck"

	checkRecipeInDB()

	updateNavbarDeck()
	if window.recipesInDeck.length is 0
		$("#main_Deck").find("#Results").html '<h2 style="color:gray;text-align:center;margin-top:5%;margin-bottom:5%;">逛食譜並加入調理台來煮飯!</h2>'
		return
	
	$.ui.showMask 'Fetching data...'
	$.ui.blockUI(0.1)

	query = ""
	for recipeId in window.recipesInDeck
		query += "recipes=#{recipeId}&"
	console.log query
	$.ajax(
		type: 'GET'
		url: "http://54.178.135.71:8080/CookIEServer/deck_recipe?#{query}"
		dataType: 'application/json'
		timeout: 10000
		success: (data)->
			data = JSON.parse data
			console.log "[SUCCESS]load deck"
			console.log data

			scope = $("#main_Deck")
			scope.find("#Results").html ""
			appendRecipeResult(scope, data, true)

			$.ui.hideMask()
			$.ui.unblockUI(0.1)
			return
		error: (resp)->
			console.log "[ERROR]load deck"
			console.log resp

			scope.find("#Resutls").html '<h2 style="color:gray;text-align:center;padding-top:5%;">Connection Error: '+resp.status+'</h2>'

			$.ui.hideMask()
			$.ui.unblockUI(0.1)
			return
	)

	return

updateNavbarDeck = ()->
	console.log "update navbar deck: #{window.recipesInDeck.length}"
	$("#navbar_deck").html "調理台(#{window.recipesInDeck.length})"
	return


parseTimeToMinutes = (time)->
	time = time.split ":"
	time = parseInt(time[0])*60 + parseInt(time[1]) + parseInt(time[2])/60

convertTimeToSeconds = (time)->
	time = time.split ":"
	time = parseInt(time[0])*3600 + parseInt(time[1])*60 + parseInt(time[2])

parseSecondsToTime = (seconds)->
	hour = Math.floor seconds/3600
	seconds %= 3600
	hour = if hour<10 then "0"+hour else hour
	min = Math.floor seconds/60
	seconds %= 60
	min = if min<10 then "0"+min else min
	seconds = if seconds<10 then "0"+seconds else seconds

	"#{hour}:#{min}:#{seconds}"

trimStringLength = (string)->
	if string.length > 14
		string = string.substring(0, 13) + "..."
	string