// Generated by CoffeeScript 1.7.1
var allCatAjaxd, appendAllCategoryResult, getAllCategory, getSingleCategory, singleCatAjaxd, singleCatId;

singleCatId = 26;

allCatAjaxd = 0;

singleCatAjaxd = 0;

// some useless comment.
// my stomach hurts

$(document).ready(function() {
  addInfiniteScroll($("#main_Browse_Category"), 1000, function() {
    return getAllCategory(allCatAjaxd);
  });
  addInfiniteScroll($("#CategoryContent"), 1000, function() {
    getSingleCategory(singleCatAjaxd, singleCatId);
  });
});

getAllCategory = function(times) {
  $.ajax({
    type: "GET",
    url: "http://54.178.135.71:8080/CookIEServer/discover_category",
    dataType: 'application/json',
    data: {
      'times': times
    },
    timeout: 10000,
    success: function(data) {
      data = JSON.parse(data);
      console.log("[SUCCESS]fetch categories");
      console.log(data);
      allCatAjaxd++;
      $("#main_Browse_Category").scroller().clearInfinite();
      if (data.length === 0) {
        $("#main_Browse_Category").find("#infinite").text("No more categories");
        allCatAjaxd--;
        return;
      }
      $("#main_Browse_Category").find("#infinite").text("Load more");
      appendAllCategoryResult(data);
    },
    error: function(resp) {
      console.log("[ERROR]fetch kitchen menu: " + resp.status);
      $("#main_Browse_Category").scroller().clearInfinite();
      if (resp.status === 0) {
        $("#main_Browse_Category").find("#infinite").text("Server Error. Try again later.");
      } else {
        $("#main_Browse_Category").find("#infinite").text("Connection Error: " + resp.status);
      }
    }
  });
};

appendAllCategoryResult = function(data) {
  var html, id, results, tag, tagGroup, _i, _j, _len, _len1, _ref;
  console.log("append all category result");
  results = $("#main_Browse_Category").find("#Results");
  results.find(".new").removeClass("new");
  for (_i = 0, _len = data.length; _i < _len; _i++) {
    tagGroup = data[_i];
    if (tagGroup.tagWithRecipe.length === 0) {
      continue;
    }
    html = '<div class="category_box" id="TagFilter' + tagGroup.tagfilter.filterId + '"><h2 style="margin-left:5px;">' + tagGroup.tagfilter.filterName + '</h2>';
    _ref = tagGroup.tagWithRecipe;
    for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
      tag = _ref[_j];
      id = tag.tag.tagId;
      html += '<div id="Tag' + id + '" class="cat_wrapper new" data-tag-id="' + id + '" data-times="0"><img class="cat_icon" src="' + tag.mostPopularRecipe.smallURL + '"><div class="cat_text">' + tag.tag.tagName + '</div></div>';
    }
    html += '</div><div class="divider">&nbsp;</div>';
    results.append(html);
  }
  results.find(".new").forEach(function(elem) {
    return $(elem).click(function() {
      var times;
      $.ui.loadContent("#CategoryContent");
      times = parseInt(this.getAttribute('data-times'));
      id = this.getAttribute('data-tag-id');
      singleCatId = id;
      singleCatAjaxd = times;
      return getSingleCategory(singleCatAjaxd, singleCatId);
    });
  });
};

getSingleCategory = function(times, tagId) {
  $.ajax({
    type: "GET",
    url: "http://54.178.135.71:8080/CookIEServer/get_tag",
    dataType: 'application/json',
    data: {
      'times': times,
      'tag_id': tagId
    },
    success: function(data) {
      var scope;
      data = JSON.parse(data);
      console.log("[SUCCESS]fetch cat " + tagId + " for " + times + " times");
      console.log(data);
      singleCatAjaxd++;
      $('#CategoryContent').scroller().clearInfinite();
      if (data.recipes.length === 0) {
        $("#CategoryContent").find("#infinite").html("No more recipes.");
        singleCatAjaxd--;
        return;
      }
      $.ui.setTitle(data.tag.tagName);
      scope = $('#CategoryContent');
      scope.find("#Results").html("");
      appendRecipeResult(scope, data.recipes);
    },
    error: function(data, status) {
      console.log("[ERROR]fetch cat #" + tagId);
      $('#CategoryContent').scroller().clearInfinite();
      $("#CategoryContent").find("#infinite").html("Error. Try Again?");
    }
  });
};
