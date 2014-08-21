getIngredientList = (recipeIds)->
	console.log "get ingredient list"

	$.ui.blockUI(0.1)
	$.ui.showMask "Updating..."

	data = ''
	#recipeIds = JSON.parse(recipeIds)
	for id in recipeIds
		data += 'recipes='+id+'&'
	$.ajax(
			type: 'GET'
			url: 'http://54.178.135.71:8080/CookIEServer/list_ingredient?'+data
			timeout: 10000
			success: (data)->
				data = JSON.parse(data)
				console.log '[SUCCESS] fetching #'+recipeIds
				console.log data

				storeIngredientListToDB(data)
				showIngredientList()

				return # avoid implicit rv
			error: (data, status)->
				console.log '[ERROR] fetching #'+recipeIds
				console.log data

				return # avoid implicit rv
	)
	return # avoid implicit rv

storeIngredientListToDB = (data)->
	console.log "store ingredient list to db"

	db.transaction (transaction)->
		transaction.executeSql 'DELETE FROM `MenuIngredients`', [],
			successCallBack,
			errorHandler
		, errorHandler, nullHandler
		return

	for ingredient in data
		AddValueToIngredient ingredient.ingredientId,
			ingredient.recipeId,
			ingredient.ingredientName,
			ingredient.amount,
			ingredient.unitName
	return

showIngredientList = ->
	if not window.openDatabase
		alert 'Databases not supported by this browser'
		return

	console.log "show ingredient list"
	$("#EmptyNotify").removeClass 'hidden'
	$("#ToBuyListCookBtn").addClass 'hidden'

	db.transaction (transaction)->
		transaction.executeSql 'SELECT * FROM MenuIngredients', [],
			(transaction,result)->
				if result? and result.rows?
					### if there's no list in the DB ###
					if result.rows.length is 0 then return

					### there's list in the DB ###
					list = $("#list")
					list.html ""
					html = ''
					for x, i in result.rows
						row = result.rows.item(i)
						html += '<li class="listEle">'+row.name+'&nbsp;'+row.amount+'&nbsp;'+row.unitName+'</li>'
					list.append html

					$('.listEle').click (event)->
						if $(this).css('textDecoration') is 'line-through'
							$(this).css 'textDecoration', 'none'
							$(this).css 'color', '#53575E'
							$(this).removeClass 'list-selected'
							$(this).removeClass 'not-moved'
						else
							$(this).css 'textDecoration', 'line-through'
							$(this).css 'color', '#D8D8D8'
							$(this).addClass 'list-selected'
							$(this).addClass 'not-moved'
						#this.style.textDecoration = if this.style.textDecoration is 'line-through' then 'none' else 'line-through'
						#this.style.color = if this.style.textDecoration is 'line-through' then '#D8D8D8' else '#53575E'
						
						clearTimeout window.lastId
						window.lastId = setTimeout ->
							moveCheckedIngredientToBottom()
						, 2000

						return
					$("#EmptyNotify").addClass 'hidden'
					$("#ToBuyListCookBtn").removeClass 'hidden'
					
					$.ui.hideMask()
					$.ui.unblockUI()
				return
			, errorHandler
		, errorHandler, nullHandler
		return

	return

moveCheckedIngredientToBottom = ->
	console.log "move checked to bottom"
	$('#list').find('.not-moved').forEach (listEle)->
		html = listEle.outerHTML
		ele = $(listEle)
		ele.css3Animate
			opacity: '0.1'
			time: '200ms'
			success: ()->
				ele.removeClass 'not-moved'
				ele.remove()
				$('#list').append html
	return

reloadToBuyList = ->
	console.log "reload to buy list"
	if not window.deckChanged then return

	if window.recipesInDeck.length is 0
		$("#list").html ""
		$("#EmptyNotify").removeClass 'hidden'
		$("#ToBuyListCookBtn").addClass 'hidden'
		return
	
	getIngredientList window.recipesInDeck
	window.deckChanged = false

	return # avoid implicit rv