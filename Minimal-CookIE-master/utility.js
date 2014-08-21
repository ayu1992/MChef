// Generated by CoffeeScript 1.7.1
var addInfiniteScroll, allCatAjaxd, convertTimeToSeconds, initSidebarIcons, loadCateogries, loadDeck, loadRecipes, parseSecondsToTime, parseTimeToMinutes, recipeAjaxd, sendFeedback, trimStringLength, updateNavbarDeck;

$(document).ready(function() {
  initSidebarIcons();
  $("#ToBuyListCookBtn").click(function() {
    getScheduledRecipe(window.recipesInDeck);
    $.ui.loadContent('Cooking');
  });
  return $("#DoneBtn").click(function() {
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
  });
});

initSidebarIcons = function() {
  $(".icon.close").click(function() {
    var ans;
    ans = confirm("這會清除您調理台與購買清單中的所有資料\n繼續？");
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
    return;
    return $.ui.loadContent("main_Browse_Recipe");
  });
};

sendFeedback = function() {
  var mail, msg, name, type, url;
  name = $("#feedbackName").val();
  mail = $("#feedbackMail").val();
  type = (function() {
    switch ($("#feedbackType").val()) {
      case '食譜請求':
        return 'recipe';
      case '臭蟲回報':
        return 'bug';
      case '意見':
        return 'feedback';
    }
  })();
  msg = $("#feedbackContent").val();
  url = "";
  $.ajax({
    type: 'POST',
    url: url,
    dataType: 'application/json',
    data: {
      'name': name,
      'mail': mail,
      'type': type,
      'message': msg
    },
    timeout: 10000,
    success: function(data) {
      data = JSON.parse(data);
      console.log("[SUCCESS] send feedback");

      /* TODO Insert token into SQL */
      alert("Thank you for your support!");
    },
    error: function(resp) {
      console.log("[ERROR] send feedback");
      if (resp.status === 0) {
        alert("Server Error. Try again later.");
      } else {
        alert("Connection error: " + resp.status);
      }
    }
  });
};

addInfiniteScroll = function(scope, delay, callback) {
  var scrollerList;
  console.log("add infinite-scroll to scope:" + scope[0].id);
  scrollerList = scope.scroller();
  scrollerList.clearInfinite();
  scrollerList.addInfinite();
  $.bind(scrollerList, 'infinite-scroll', function() {
    console.log(scope[0].id + " infinite-scroll");
    scope.find("#infinite").text("Loading more...");
    scrollerList.addInfinite();
    clearTimeout(window.lastId);
    return window.lastId = setTimeout(function() {
      return callback();
    }, delay);
  });
};

recipeAjaxd = 0;

loadRecipes = function() {
  var scope;
  console.log("load recipes");
  scope = $('#main_Browse_Recipe');
  scope.find('#Results').html("");
  scope.find("#infinite").text("Reloading...");
  recipeAjaxd = 0;
  getRecipes(recipeAjaxd);
  updateNavbarDeck();
};

allCatAjaxd = 0;

loadCateogries = function() {
  var scope;
  console.log("load categories");
  scope = $("#main_Browse_Category");
  scope.find("#Results").html("");
  scope.find("#infinite").text("Loading...");
  allCatAjaxd = 0;
  getAllCategory(allCatAjaxd);
};

loadDeck = function() {
  var query, recipeId, _i, _len, _ref;
  console.log("loading deck");
  checkRecipeInDB();
  updateNavbarDeck();
  if (window.recipesInDeck.length === 0) {
    $("#main_Deck").find("#Results").html('<h2 style="color:gray;text-align:center;margin-top:5%;margin-bottom:5%;">逛食譜並加入調理台來煮飯!</h2>');
    return;
  }
  $.ui.showMask('Fetching data...');
  $.ui.blockUI(0.1);
  query = "";
  _ref = window.recipesInDeck;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    recipeId = _ref[_i];
    query += "recipes=" + recipeId + "&";
  }
  console.log(query);
  $.ajax({
    type: 'GET',
    url: "http://54.178.135.71:8080/CookIEServer/deck_recipe?" + query,
    dataType: 'application/json',
    timeout: 10000,
    success: function(data) {
      var scope;
      data = JSON.parse(data);
      console.log("[SUCCESS]load deck");
      console.log(data);
      scope = $("#main_Deck");
      scope.find("#Results").html("");
      appendRecipeResult(scope, data, true);
      $.ui.hideMask();
      $.ui.unblockUI(0.1);
    },
    error: function(resp) {
      console.log("[ERROR]load deck");
      console.log(resp);
      scope.find("#Resutls").html('<h2 style="color:gray;text-align:center;padding-top:5%;">Connection Error: ' + resp.status + '</h2>');
      $.ui.hideMask();
      $.ui.unblockUI(0.1);
    }
  });
};

updateNavbarDeck = function() {
  console.log("update navbar deck: " + window.recipesInDeck.length);
  $("#navbar_deck").html("調理台(" + window.recipesInDeck.length + ")");
};

parseTimeToMinutes = function(time) {
  time = time.split(":");
  return time = parseInt(time[0]) * 60 + parseInt(time[1]) + parseInt(time[2]) / 60;
};

convertTimeToSeconds = function(time) {
  time = time.split(":");
  return time = parseInt(time[0]) * 3600 + parseInt(time[1]) * 60 + parseInt(time[2]);
};

parseSecondsToTime = function(seconds) {
  var hour, min;
  hour = Math.floor(seconds / 3600);
  seconds %= 3600;
  hour = hour < 10 ? "0" + hour : hour;
  min = Math.floor(seconds / 60);
  seconds %= 60;
  min = min < 10 ? "0" + min : min;
  seconds = seconds < 10 ? "0" + seconds : seconds;
  return "" + hour + ":" + min + ":" + seconds;
};

trimStringLength = function(string) {
  if (string.length > 14) {
    string = string.substring(0, 13) + "...";
  }
  return string;
};