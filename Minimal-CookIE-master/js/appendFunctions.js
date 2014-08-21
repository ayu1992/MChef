// Generated by CoffeeScript 1.7.1
var appendRecipeResult;
clearDeck = function(){
    var ans;
    ans = confirm("這會清除Deck所有資料\n繼續？");
    if (ans === false) {
      return;
    }
    db.transaction(function(transaction) {
      var sql;
      sql = 'DELETE FROM `Recipes`';
      transaction.executeSql(sql, [], successCallBack, errorHandler);
      sql = 'DELETE FROM `MenuIngredients`';
      transaction.executeSql(sql, [], function() {
        $("#ToBuyListCookBtn").addClass('hidden');
        $("#EmptyNotify").removeClass('hidden');
        window.recipesInDeck = [];
        loadDeck();
        return loadRecipes();
      }, errorHandler);
    }, errorHandler, nullHandler);
	console.log("fuck");
    $("#EmptyNotify").addClass('hidden');
    $("#ToBuyListCookBtn").removeClass('hidden');
    $("#list").html("");
    window.cookingData = null;
    window.currentStepNum = 0;
    window.currentStep = null;
    window.currentTime = 0;
    window.waitingStepQueue = [];
    window.stepsTimeUsed = [];
    window.cookingStartTime = null;
    return $.ui.loadContent("main_Deck");
}
appendRecipeResult = function(scope, data, deck) {
  var count, exist, html, id, name, recipe, results, thisRecipe, url, _i, _len;
  if (deck == null) {
    deck = 0;
  }
  console.log("append recipe for scope: " + scope[0].id);
  results = scope.find("#Results");
  results.find('.new').removeClass('new');
  count = 0;
  for (_i = 0, _len = data.length; _i < _len; _i++) {
    recipe = data[_i];
    html = '';
    id = recipe.recipe_id;
    name = recipe.name;
    url = recipe.smallURL;
    exist = checkRecipeInDeck(id) ? true : false;
    if (deck) {
      html += '<div class="recipe_item long" id="Recipe' + id + '" data-recipe-id="' + id + '">';
    } else {
      if (count % 2) {
        html += '<div class="recipe_item right new" id="Recipe' + id + '" data-recipe-id="' + id + '">';
      } else {
        html += '<div class="recipe_item left new" id="Recipe' + id + '" data-recipe-id="' + id + '">';
      }
    }
    if (deck) {
      html += '<img class="recipe_image_wrapper long" src="' + url + '">';
      html += '<div class="recipe_descrip long chinese_font">' + name + '</div>';
      html += '<div class="recipe_time long chinese_font">需時 ' + recipe.costTime + '</div>';
    } else {
      html += '<img class="recipe_image_wrapper" src="' + url + '">';
      html += '<div class="recipe_descrip chinese_font">' + name + '</div>';
    }
    if (!deck) {
      html += '<div class="recipe_cooked">人氣：' + recipe.popularity + '</div>';
    }
    if (!exist) {
      html += '<div class="button recipe_btn recipe_add_btn chinese_font">加到調理台</div>';
    } else if (deck) {
      html += '<div class="button recipe_btn recipe_remove_btn chinese_font">移除</div>';
    } else {
      html += '<div class="button recipe_btn recipe_in_deck_btn chinese_font" >已加入調理台</div>';
    }
    html += '</div>';
    results.append(html);
    count++;
    thisRecipe = scope.find("#Recipe" + id);
    thisRecipe.find("img").click((function(id) {
      return function() {
        $.ui.loadContent("#RecipeContent");
        $("#RecipeContent").find("#Results").hide();
        $("#RecipeContent").find("#Loading").show();
        getRecipeContent(id);
      };
    })(id));
    if (!exist) {
      thisRecipe.find(".recipe_btn").click((function(id, thisRecipe) {
        return function() {
          addThisRecipeToDeck(id);
          if (window.recipesInDeck.length >= 6) {
            return;
          }
          thisRecipe.find(".recipe_btn")[0].outerHTML = '<div class="button recipe_btn recipe_in_deck_btn chinese_font">已加入調理台</div>';
        };
      })(id, thisRecipe));
    } else if (deck) {
      thisRecipe.find(".recipe_btn").click((function(id) {
        return function() {
          deleteThisRecipeFromDeck(id);
        };
      })(id));
    }
  }
  results.find("#bottomBar").remove();
  results.append('<div id="bottomBar" style="display:block;height:0;clear:both;">&nbsp;</div>');
  scope.find("#infinite").text("Load More");
};