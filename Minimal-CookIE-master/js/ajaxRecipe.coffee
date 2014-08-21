recipeAjaxd = 0

$(document).ready ->
	addInfiniteScroll $('#main_Browse_Recipe'), 1000, ->
		if $('#main_Browse_Recipe').find("Results").hasClass "hidden" then search window.query, searchAjaxd
		else getRecipes(recipeAjaxd)
		return
	return #avoid implicit return values by Coffeescript

getRecipes = (times) ->
	$.ajax(
		type: "GET"
		url: 'http://54.178.135.71:8080/CookIEServer/discover_recipes'
		#dataType: 'jsonp'
		#crossDomain: true
		#jsonp: false
		dataType: 'application/json'
		data: 
			'type': 'popular'
			'times': times
		timeout: 10000
		success: (data)->
			data = JSON.parse(data)
			console.log "[SUCCESS]fetch recipes"
			console.log data

			recipeAjaxd++

			$('#main_Browse_Recipe').scroller().clearInfinite()

			if data.length is 0
				$("#main_Browse_Recipe").find("#infinite").text "No more recipes"
				recipeAjaxd--
				return

			scope = $("#main_Browse_Recipe")
			appendRecipeResult(scope, data)
			return #avoid implicit return values by Coffeescript
		error: (resp)->
			console.log "[ERROR]fetch recipes"
			console.log resp
			if resp.status is 0
				$("#main_Browse_Recipe").find("#infinite").text "Server Error. Try again later."
			else
				$("#main_Browse_Recipe").find("#infinite").text "Connection Error: #{resp.status}"
			$('#main_Browse_Recipe').scroller().clearInfinite()
			return #avoid implicit return values by Coffeescript
	)
	return #avoid implicit return values by Coffeescript
	