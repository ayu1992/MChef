getScheduledRecipe = (recipeIds)->
	if window.cookingData?
		ans = confirm "You have a cooking in progress. Resume?"
		if ans is yes
			$.ui.loadContent "Step"
			return
			
	console.log "schedule_recipe #"+recipeIds
	$.ui.updatePanel "Cooking",""
	$.ui.showMask "Loading data from server..."
	$.ui.blockUI(.1)

	data = ''
	#recipeIds = JSON.parse(recipeIds)
	for id in recipeIds
		data += 'recipes='+id+'&'
	$.ajax(
			type: 'GET'
			url: 'http://54.178.135.71:8080/CookIEServer/schedule_recipe?'+data
			#timeout: 10000
			success: (data)->
				data = JSON.parse(data)
				console.log '[SUCCESS] fetching #'+recipeIds
				console.log data

				scope = $('#Cooking')
				window.cookingData = data
				window.currentStepNum = 0
				appendData scope, data

				return # avoid implicit rv
			error: (resp)->
				console.log '[ERROR] fetching #'+recipeIds
				console.log resp
				$.ui.hideMask()
				if resp.status is 404 then alert "Server aborted the scheduling process. Please try again with fewer recipes."
				else if resp.status is 0 then alert "Server Error. Try again later."
				else alert "Connection error: #{resp.status}"
				$.ui.loadContent "main_Deck"
				return # avoid implicit rv
	)
	return

appendData = (scope, data)->
	console.log "append steps"

	###
	scope.find("#totalRecipes").html data.recipeLength.length
	scope.find("#originalCookingTime").html data.originTime
	scope.find("#scheduledCookingTime").html data.scheduledTime
	###

	$.ui.updatePanel "Cooking",""+
		'<div style="background-color:#F2F2F2">'+
			'<h2 style="margin-left:5%;margin-top:5%">本次共有 <span id="totalRecipes">'+data.recipeLength.length+'</span> 道食譜排程</h2>'+
			'<h2 style="margin-left:5%;">原本需要時間：</h2>'+
			'<i id="originalCookingTime" style="margin-left:7%;font-size:17px;">'+data.originTime+'</i>'+
			'<h2 style="margin-left:5%;">排程優化時間：</h2>'+
			'<i id="scheduledCookingTime" style="margin-left:7%;font-size:17px;">'+data.scheduledTime+'</i>'+
			'<br />'+
			'<div class="bottom_btn_holder" style="margin-top:80%;">'+
				'<a class="button" style="width:100%;background: hsl(204.1,35%,53.1%);height:10%;color:white;text-shadow: -1px -1px gray;border-radius: 8px;" href="#Step">開始！</a>'+
			'</div>'+
		'</div>'


	$.ui.unblockUI()
	$.ui.hideMask();
	return
