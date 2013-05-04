// User
var userB64 = null;
var sessionStarted = false;
var editComment = 0;

/*
* JQuery Case Insensitive :icontains selector
*/
$.expr[':'].icontains = function(obj, index, meta, stack){
	return (obj.textContent.replace(/\[[0-9]+\]/g, "") || obj.innerText.replace(/\[[0-9]+\]/g, "") || jQuery(obj).text().replace(/\[[0-9]+\]/g, "") || '').toLowerCase().indexOf(meta[3].toLowerCase()) >= 0;
};

/*
 *	Quick Search global vars
 */
 
// Current search results preview table
var currentTable = null;

//Hightlighted index in search result preview table
var currentIndex = -1;


/*
* Add folding and filtering facilities to class description page.
*/
$(document).ready(function() {

	// Hide edit tags
	$('textarea').hide();
	$('a[id=commitBtn]').hide();
	$('a[id=cancelBtn]').hide();
	// Hide Authenfication form
	$(".popover").hide();    
    // Update display
    updateDisplaying();
	
	/*
	* Highlight the spoted element
	*/
	highlightBlock(currentAnchor());

	/*
	* Nav block folding
	*/
	
	// Menu nav folding
	$(".menu nav h3")
	.prepend(
		$(document.createElement("a"))
		.html("-")
		.addClass("fold")
	)
	.css("cursor", "pointer")
	.click( function() {
			if($(this).find("a.fold").html() == "+") {
				$(this).find("a.fold").html("-");
			} else {
				$(this).find("a.fold").html("+");
			}
			$(this).nextAll().toggle();
	})
	
	// Insert search field
	$("nav.main ul")
	.append(
		$(document.createElement("li"))
		.append(
			$(document.createElement("form"))
			.append(
				$(document.createElement("input"))
				.attr({
					id: "search",
					type:	"text",
					autocomplete: "off",
					value: "quick search..."
				})
				.addClass("notUsed")

				// Key management
				.keyup(function(e) {
					switch(e.keyCode) {

						// Select previous result on "Up"
						case 38:
							// If already on first result, focus search input
							if(currentIndex == 0) {
								$("#search").val($(currentTable.find("tr")[currentIndex]).data("searchDetails").name);
								$("#search").focus();
							// Else select previous result
							} else if(currentIndex > 0) {
								$(currentTable.find("tr")[currentIndex]).removeClass("activeSearchResult");
								currentIndex--;
								$(currentTable.find("tr")[currentIndex]).addClass("activeSearchResult");
								$("#search").val($(currentTable.find("tr")[currentIndex]).data("searchDetails").name);
								$("#search").focus();
							}
						break;

						// Select next result on "Down"
						case 40:
							if(currentIndex < currentTable.find("tr").length - 1) {
								$(currentTable.find("tr")[currentIndex]).removeClass("activeSearchResult");
								currentIndex++;
								$(currentTable.find("tr")[currentIndex]).addClass("activeSearchResult");
								$("#search").val($(currentTable.find("tr")[currentIndex]).data("searchDetails").name);
								$("#search").focus();
							}
						break;
						// Go to url on "Enter"
						case 13:
							if(currentIndex > -1) {
								window.location = $(currentTable.find("tr")[currentIndex]).data("searchDetails").url;
								return false;
							}
							if($("#search").val().length == 0)
								return false
				
							window.location = "full-index.html#q=" + $("#search").val();
							if(window.location.href.indexOf("full-index.html") > -1) {
								location.reload();
							}				
							return false;
						break;

						// Hide results preview on "Escape"
						case 27:
							$(this).blur();
							if(currentTable != null) {
								currentTable.remove();
								currentTable = null;
							}
						break;

						default:
							if($("#search").val().length == 0) {
								return false;
							}
						
							// Remove previous table
							if(currentTable != null) {
								currentTable.remove();
							}

							// Build results table
							currentIndex = -1;
							currentTable = $(document.createElement("table"));

							// Escape regexp related characters in query
							var query = $("#search").val();
							query = query.replace(/\[/gi, "\\[");
							query = query.replace(/\|/gi, "\\|");
							query = query.replace(/\*/gi, "\\*");
							query = query.replace(/\+/gi, "\\+");
							query = query.replace(/\\/gi, "\\\\");
							query = query.replace(/\?/gi, "\\?");
							query = query.replace(/\(/gi, "\\(");
							query = query.replace(/\)/gi, "\\)");

							var index = 0;
							var regexp = new RegExp("^" + query, "i");
							for(var entry in entries) {
								if(index > 10) {
									break;
								}
								var result = entry.match(regexp);
								if(result != null && result.toString().toUpperCase() == $("#search").val().toUpperCase()) {
									for(var i = 0; i < entries[entry].length; i++) {
										if(index > 10) {
											break;
										}
										currentTable.append(
											$(document.createElement("tr"))
											.data("searchDetails", {name: entry, url: entries[entry][i]["url"]})
											.data("index", index)
											.append($(document.createElement("td")).html(entry))
											.append(
												$(document.createElement("td"))
													.addClass("entryInfo")
													.html(entries[entry][i]["txt"] + "&nbsp;&raquo;"))
											.mouseover( function() {
												$(currentTable.find("tr")[currentIndex]).removeClass("activeSearchResult");
												$(this).addClass("activeSearchResult");
												currentIndex = $(this).data("index");
											})
											.mouseout( function() {
												$(this).removeClass("activeSearchResult");
											 })
											.click( function() {
												window.location = $(this).data("searchDetails")["url"];
											})
										);
										index++;
									}
								}
							}
							
							// Initialize table properties
							currentTable.attr("id", "searchTable");
							currentTable.css("position", "absolute");
							currentTable.width($("#search").outerWidth());
							$("header").append(currentTable);
							currentTable.offset({left: $("#search").offset().left + ($("#search").outerWidth() - currentTable.outerWidth()), top: $("#search").offset().top + $("#search").outerHeight()});

							// Preselect first entry
							if(currentTable.find("tr").length > 0) {
								currentIndex = 0;
								$(currentTable.find("tr")[currentIndex]).addClass("activeSearchResult");
								$("#search").focus();
							}
						break;
					}
				})
				.focusout(function() {
					if($(this).val() == "") {
						$(this).addClass("notUsed");
						$(this).val("quick search...");
					}
				})
				.focusin(function() {
					if($(this).val() == "quick search...") {
						$(this).removeClass("notUsed");
						$(this).val("");
					}
				})
			)
			.submit( function() {
				return false;
			})
		)
	 );

	 // Close quicksearch list on click
	 $(document).click(function(e) {
		if(e.target != $("#search")[0] && e.target != $("#searchTable")[0]) {
			if(currentTable != null) {
				currentTable.remove();
				currentTable = null;
			}
		}
	 });
	
	// Insert filter field
	$("article.filterable h2, nav.filterable h3")
	.after(
		$(document.createElement("div"))
		.addClass("filter")
		.append(
			$(document.createElement("input"))
			.attr({
				type:	"text",
				value:	"filter..."
			})
			.addClass("notUsed")
			.keyup(function() {
				$(this).parent().parent().find("ul li:not(:icontains('" + $(this).val() + "'))").addClass("hide");
				$(this).parent().parent().find("ul li:icontains('" + $(this).val() + "')").removeClass("hide");
			})
			.focusout(function() {
				if($(this).val() == "") {
					$(this).addClass("notUsed");
					$(this).val("filter...");
				}
			})
			.focusin(function() {
				if($(this).val() == "filter...") {
					$(this).removeClass("notUsed");
					$(this).val("");
				}
			})
		)
	);
	
	// Filter toggle between H I R in nav porperties list
	$("nav.properties.filterable .filter")
	.append(
		$(document.createElement("a"))
		.html("H")
		.attr({
			title:	"hide inherited properties"
		})
		.click( function() {
			if($(this).hasClass("hidden")) {
				$(this).parent().parent().find("li.inherit").show();
			} else {
				$(this).parent().parent().find("li.inherit").hide();
			}
			
			$(this).toggleClass("hidden");
		})
	)
	.append(
		$(document.createElement("a"))
		.html("R")
		.attr({
			title:	"hide redefined properties"
		})
		.click( function() {
			if($(this).hasClass("hidden")) {
				$(this).parent().parent().find("li.redef").show();
			} else {
				$(this).parent().parent().find("li.redef").hide();
			}
			
			$(this).toggleClass("hidden");
		})
	)
	.append(
		$(document.createElement("a"))
		.html("I")
		.attr({
			title:	"hide introduced properties"
		})
		.click( function() {
			if($(this).hasClass("hidden")) {
				$(this).parent().parent().find("li.intro").show();
			} else {
				$(this).parent().parent().find("li.intro").hide();
			}
			
			$(this).toggleClass("hidden");
		})
	);
	
	// Filter toggle between I R in 
	$("article.properties.filterable .filter, article.classes.filterable .filter")
	.append(
		$(document.createElement("a"))
		.html("I")
		.attr({
			title:	"hide introduced properties"
		})
		.click( function() {
			if($(this).hasClass("hidden")) {
				$(this).parent().parent().find("li.intro").show();
			} else {
				$(this).parent().parent().find("li.intro").hide();
			}
			
			$(this).toggleClass("hidden");
		})
	)
	.append(
		$(document.createElement("a"))
		.html("R")
		.attr({
			title:	"hide redefined properties"
		})
		.click( function() {
			if($(this).hasClass("hidden")) {
				$(this).parent().parent().find("li.redef").show();
			} else {
				$(this).parent().parent().find("li.redef").hide();
			}
			
			$(this).toggleClass("hidden");
		})
	);

	/*
	* Anchors jumps
	*/
	$("a[href*='#']").click( function() {
		highlightBlock($(this).attr("href").split(/#/)[1]);
	});
	
	//Preload filter fields with query string
	preloadFilters();

    // If cookie existing the session is opened
    if(sessionStarted != false)	{ userB64 = "Basic " + getUserPass("logginNitdoc"); }

    // Display Login modal
    $("#logGitHub").click(function(){ displayLogginModal(); }); 

    // Sign In an github user or Log out him
	$("#signIn").click(function(){
		if(sessionStarted == false){
			if($('#loginGit').val() == "" || $('#passwordGit').val() == ""){ displayMessage('The comment field is empty!', 40, 45); }
			else
			{
				userName = $('#loginGit').val();
				password = $('#passwordGit').val();
				repoName = $('#repositoryGit').val();
				branchName = $('#branchGit').val();
				userB64 = "Basic " +  base64.encode(userName+':'+password);
				setCookie("logginNitdoc", base64.encode(userName+':'+password+':'+repoName+':'+branchName), 1);				
				$('#loginGit').val("");
				$('#passwordGit').val("");
			}
		}	
		else
		{
			// Delete cookie and reset settings
			del_cookie("logginNitdoc");
		}	
		displayLogginModal();
	});

	// Open edit file
   	$('pre[class=text_label]').click(function(){
   			// the customer is loggued ?
			if(sessionStarted == false || userName == ""){
				// No => nothing happen
				return;
			}
			else{
   			var arrayNew = $(this).text().split('\n');	
			var lNew = arrayNew.length - 1;
			var adapt = "";

			for (var i = 0; i < lNew; i++) {
		        adapt += arrayNew[i];		     
		    	if(i < lNew-1){ adapt += "\n"; }
		    }

   			editComment += 1;
   			// hide comment
        	$(this).hide();
        	// Show edit box 
        	$(this).next().show();
        	// Show cancel button
        	$(this).next().next().show();  
        	// Show commit button
        	$(this).next().next().next().show();
        	// Add text in edit box      
        	if($(this).next().val() == ""){ $(this).next().val(adapt); }
        	// Resize edit box 
    		$(this).next().height($(this).next().prop("scrollHeight"));
    		// Select it
        	$(this).next().select();
        	preElement = $(this);   
    	}  
    });

   	$('a[id=cancelBtn]').click(function(){
   	 	if(editComment > 0){ editComment -= 1; }
   	 	// Hide itself
   	 	$(this).hide();
   	 	// Hide commitBtn
   	 	$(this).next().hide();
   	 	// Hide Textarea
   	 	$(this).prev().hide();
   	 	// Show comment
   	 	$(this).prev().prev().show();
   	 });

});

/* Parse current URL and return anchor name */
function currentAnchor() {  
    var index = document.location.hash.indexOf("#");
    if (index >= 0) {
		return document.location.hash.substring(index + 1);
	}
	return null;
}

/* Prealod filters field using search query */
function preloadFilters() {
	// Parse URL and get query string
	var search = currentAnchor();
	
	if(search == null || search.indexOf("q=") == -1)
		return;
		
	search = search.substring(2, search.length);	
	
	if(search == "" || search == "undefined")
		return;
	
	$(":text").val(search);
	$(".filter :text")
		.removeClass("notUsed")
		.trigger("keyup");

}

/* Hightlight the spoted block */
function highlightBlock(a) {
	if(a == undefined) {
		return;
	}

	$(".highlighted").removeClass("highlighted");
	
	var target = $("#" + a);
	
	if(target.is("article")) {
		target.parent().addClass("highlighted");
	}
	
	target.addClass("highlighted");
	target.show();
}

function displayLogginModal(){
	if ($('.popover').is(':hidden')) { $('.popover').show(); }
	else { $('.popover').hide(); }	
	updateDisplaying();
}

function updateDisplaying(){
	if (checkCookie() == true)
	{
	  	$('#loginGit').hide();
	  	$('#passwordGit').hide();
	  	$('#lbpasswordGit').hide();		
	  	$('#lbloginGit').hide();	
	  	$('#repositoryGit').hide();
	  	$('#lbrepositoryGit').hide();
	  	$('#lbbranchGit').hide();  
	  	$('#branchGit').hide();   			  		 
	  	$("#liGitHub").attr("class", "current");
	  	$("#imgGitHub").attr("src", "resources/icons/github-icon-w.png");
	  	$('#nickName').text(userName);	  	
	  	$('#githubAccount').attr("href", "https://github.com/"+userName);
	  	$('#logginMessage').css({'display' : 'block'});
	  	$('#logginMessage').css({'text-align' : 'center'});	
	  	$('.popover').css({'height' : '80px'});	
	  	$('#signIn').text("Sign out");	
	  	sessionStarted = true;
	}
	else
	{
		sessionStarted = false;
		$('#logginMessage').css({'display' : 'none'});
		$("#liGitHub").attr("class", "");
	  	$("#imgGitHub").attr("src", "resources/icons/github-icon.png");
	  	$('#loginGit').val("");
		$('#passwordGit').val("");
		$('#nickName').text("");
  		$('.popover').css({'height' : '280px'});	
  		$('#logginMessage').css({'display' : 'none'});
  		$('#repositoryGit').val($('#repoName').attr('name'));
	  	$('#branchGit').val('wikidoc');  
	  	$('#signIn').text("Sign In");
		$('#loginGit').show();
	  	$('#passwordGit').show();
	  	$('#lbpasswordGit').show();
	  	$('#lbloginGit').show();	
	  	$('#repositoryGit').show();
	  	$('#lbrepositoryGit').show();
	  	$('#lbbranchGit').show();  
	  	$('#branchGit').show();  
	}
}

function setCookie(c_name, value, exdays)
{
	var exdate=new Date();
	exdate.setDate(exdate.getDate() + exdays);
	var c_value=escape(value) + ((exdays==null) ? "" : "; expires="+exdate.toUTCString());
	document.cookie=c_name + "=" + c_value;
}

function del_cookie(c_name)
{
    document.cookie = c_name + '=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
}

function getCookie(c_name)
{
	var c_value = document.cookie;
	var c_start = c_value.indexOf(" " + c_name + "=");
	if (c_start == -1) { c_start = c_value.indexOf(c_name + "="); }
	if (c_start == -1) { c_value = null; }
	else
	{
		c_start = c_value.indexOf("=", c_start) + 1;
		var c_end = c_value.indexOf(";", c_start);
	  	if (c_end == -1) { c_end = c_value.length; }
		c_value = unescape(c_value.substring(c_start,c_end));
	}
	return c_value;
}

function getUserPass(c_name){
	var cookie = base64.decode(getCookie(c_name));
	return base64.encode(cookie.split(':')[0] + ':' + cookie.split(':')[1]);
}

function checkCookie()
{
	var cookie=getCookie("logginNitdoc");
	if (cookie!=null && cookie!="")
	{
		cookie = base64.decode(cookie);
		userName = cookie.split(':')[0];
		repoName = cookie.split(':')[2];		
		branchName = cookie.split(':')[3];
	  	return true;
	}
	else { return false; }
}


/*
* Base64
*/
base64 = {};
base64.PADCHAR = '=';
base64.ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
base64.getbyte64 = function(s,i) {
    // This is oddly fast, except on Chrome/V8.
    //  Minimal or no improvement in performance by using a
    //   object with properties mapping chars to value (eg. 'A': 0)
    var idx = base64.ALPHA.indexOf(s.charAt(i));
    if (idx == -1) {
    throw "Cannot decode base64";
    }
    return idx;
}

base64.decode = function(s) {
    // convert to string
    s = "" + s;
    var getbyte64 = base64.getbyte64;
    var pads, i, b10;
    var imax = s.length
    if (imax == 0) {
        return s;
    }

    if (imax % 4 != 0) {
    throw "Cannot decode base64";
    }

    pads = 0
    if (s.charAt(imax -1) == base64.PADCHAR) {
        pads = 1;
        if (s.charAt(imax -2) == base64.PADCHAR) {
            pads = 2;
        }
        // either way, we want to ignore this last block
        imax -= 4;
    }

    var x = [];
    for (i = 0; i < imax; i += 4) {
        b10 = (getbyte64(s,i) << 18) | (getbyte64(s,i+1) << 12) |
            (getbyte64(s,i+2) << 6) | getbyte64(s,i+3);
        x.push(String.fromCharCode(b10 >> 16, (b10 >> 8) & 0xff, b10 & 0xff));
    }

    switch (pads) {
    case 1:
        b10 = (getbyte64(s,i) << 18) | (getbyte64(s,i+1) << 12) | (getbyte64(s,i+2) << 6)
        x.push(String.fromCharCode(b10 >> 16, (b10 >> 8) & 0xff));
        break;
    case 2:
        b10 = (getbyte64(s,i) << 18) | (getbyte64(s,i+1) << 12);
        x.push(String.fromCharCode(b10 >> 16));
        break;
    }
    return x.join('');
}

base64.getbyte = function(s,i) {
    var x = s.charCodeAt(i);
    if (x > 255) {
        throw "INVALID_CHARACTER_ERR: DOM Exception 5";
    }
    return x;
}


base64.encode = function(s) {
    if (arguments.length != 1) {
    throw "SyntaxError: Not enough arguments";
    }
    var padchar = base64.PADCHAR;
    var alpha   = base64.ALPHA;
    var getbyte = base64.getbyte;

    var i, b10;
    var x = [];

    // convert to string
    s = "" + s;

    var imax = s.length - s.length % 3;

    if (s.length == 0) {
        return s;
    }
    for (i = 0; i < imax; i += 3) {
        b10 = (getbyte(s,i) << 16) | (getbyte(s,i+1) << 8) | getbyte(s,i+2);
        x.push(alpha.charAt(b10 >> 18));
        x.push(alpha.charAt((b10 >> 12) & 0x3F));
        x.push(alpha.charAt((b10 >> 6) & 0x3f));
        x.push(alpha.charAt(b10 & 0x3f));
    }
    switch (s.length - imax) {
    case 1:
        b10 = getbyte(s,i) << 16;
        x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
               padchar + padchar);
        break;
    case 2:
        b10 = (getbyte(s,i) << 16) | (getbyte(s,i+1) << 8);
        x.push(alpha.charAt(b10 >> 18) + alpha.charAt((b10 >> 12) & 0x3F) +
               alpha.charAt((b10 >> 6) & 0x3f) + padchar);
        break;
    }
    return x.join('');
}

$.fn.spin = function(opts) {
  this.each(function() {
    var $this = $(this),
        data = $this.data();

    if (data.spinner) {
      data.spinner.stop();
      delete data.spinner;
    }
    if (opts !== false) {
      data.spinner = new Spinner($.extend({color: $this.css('color')}, opts)).spin(this);
    }
  });
  return this;
};