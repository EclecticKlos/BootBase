$(document).ready(function(){

////////////// vvv SEARCH  vvv ////////////////

  var responses = {};
  var pending = false;

  var searchTimeout;
  $('.project-search').on('keyup', function(event){
    // event.preventDefault
    var query = $(this).find('.search-box').val();
    // console.log(query);

    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(function(){
      searchForProjects(query);
    }, 300);
    // searchForMatchingKeywords(query)
  })

  var LAST_SEARCH_REQUEST;
  var searchForProjects = function(query){
    // if(!query) {
    //   return;
    // }
    // // have you queried for this before?(does the key exist in responses dictionary):
    // if(responses.hasOwnProperty(query)) {
    //   $('.project-search-results').html(responses[query]);
    //   return;
    // }

    if (LAST_SEARCH_REQUEST){
      console.log('aborting last request');
      LAST_SEARCH_REQUEST.abort()
      LAST_SEARCH_REQUEST = null;
    }

    var request = $.ajax({
      url: '/projects',
      type: 'GET',
      data: {query: query},
    });
    LAST_SEARCH_REQUEST = request;
    request.done(function(projects){
      console.log(projects)
      responses[query] = projects;
      $('.project-search-results').html(projects)
    })
  }

////////////// vvv TAG VOTING  vvv ///////////////

  $('.vote').on('click', function(event){
    event.preventDefault();
    var clicked_html = this;
    var clicked_html_href = clicked_html.href;
    var just_route = clicked_html_href.replace('http://127.0.0.1:9393','');
    var voteButton = $(this);
    var voteID = voteButton.parent().attr('id');

    var request = $.ajax({
      url:  voteButton.attr("href"),
      type: "POST",
      data: {},
      dataType: "json"
    });

    request.done(function(responseData){
      var idValue = (clicked_html.id == "no_vote") ? 'voted' : 'no_vote';
      $('[href="' + just_route + '"]').attr('id',idValue);
      voteButton.find('.tag-vote-count').text(responseData.vote_count);
    })
  })

////////////// ^^^ TAG VOTING  ^^^ ///////////////

////////////// vvv DISPLAY EXAMPLE CODE  vvv ///////////////
  $('.example-code-submit').on('click', function(event){
    event.preventDefault();
    code_URL = $('.project-code-url-box').val()

    var request = $.ajax({
      url:  '/html_code_example',
      type: "GET",
      data: {code: code_URL},
      dataType: "json"
    });
    request.done(function(responseData){
      console.log(responseData)
      $('code').text(responseData);
    })
  })



})  //End of document.ready







/////////////////////  vv CHRISTINE'S SUGGESTION FOR TAG VOTING

  // $('.project-search').on('entersomethingbkah', function(event){
  //   var query = $(this).val();
  //   // console.log(query);
  //   searchForProjects(query)
  // })

  // searchForMatchingKeywords = function(query){
  //   var request = $.ajax({
  //     url: '/unique_path', //build a controller for this
  //     type: 'GET',
  //     data: {query: query},
  //   });
  //   request.done(function(projects){
  //     $('.project-search dropdown').html(projects) //append whatever jquery dropdown on the search bar thing
  //   })
  // }
/////////////////////  ^^ CHRISTINE'S SUGGESTION FOR TAG VOTING








  // var getProjectList = function(event){
  //   // event.preventDefault();
  //   var request = $.ajax({
  //     url: '/projects',
  //     type: 'GET',
  //   });
  //  console.log("hello")
  //   request.done(function(data){
  //     console.log(data)
  //     $('body').append(data)
  //   })
  // };


  // // getProjectList();








// $(document).ready(function(){

//   var updateClock = function(){
//     var request = $.ajax({
//       url: '/current-time',
//       type: 'GET',
//     });

//     request.done(function(data){
//       $('.clock').text(data);
//     });
//   }

//   setInterval(updateClock, 1000);

// });





























// $(document).ready(function() {
//   bindEvents();
// });

// function bindEvents() {

// }

// var git_request = function(e){
//   e.preventDefault()

//   $.ajax({
//     url:        'https://github.com/login/oauth.authorize'
//     type:       'POST'
//     dataType:   'json'
//     data: {
//       client_id=    '76e09f72b75dbea43129'
//       redirect_uri= 'http://127.0.0.1:9393/projects'
//       scope=        user:email,user:follow,repo,repo_deployment,red:repo_hook
//       state=        'thisrandomestringofcharsxxxxxxaoeiCod2fgDo45iuRsd14fu'
//     })
//     .done(function(serverData){
//       console.log(serverData)
//     })
//   }
// })
// }

// // function bindEvents() {
// //   $('#new-todo').on('submit',addTodo);
// //   $('.delete').on('click', removeTodo);
// //   $('.complete').on('click',completeTodo);
// // }


// // var addTodo = function(e){
// //     e.preventDefault()

// //   var formData = $(this).serialize()
// //   $.ajax({
// //     url: "/add_todo",
// //     method: "POST",
// //     data: formData
// //   })
// //   .done(function(serverData){
// //     console.log(serverData.id)
// //     $(".todo_list").append(buildTodo(serverData));
// //   })
// //   .fail(function(){
// //     console.log("fail")
// //   })

// // }

// // var removeTodo = function(e){
// //   e.preventDefault()

// //   var todoToDelete= $(this).closest("div");

// //   $.ajax({
// //     url: $(this).attr('href'),
// //     method: "DELETE",
// //   })
// //   .done(function(){
// //     todoToDelete.remove();
// //   })
// //   .fail(function(){
// //     console.log("fail")
// //   })
// // }

// // var completeTodo = function(e){
// //   e.preventDefault()

// //   var todoToComplete = $(this).closest('div')
// //   $.ajax({
// //     url: $(this).attr('href'),
// //     method: "PUT",
// //   })
// //   .done(function(serverData){
// //     alert("Completed " + serverData.todo_content)
// //   })
// //   .fail(function(){
// //     console.log("fail")
// //   })
// // }

// // function buildTodo(todoName) {
// //   var todoTemplate = $.trim($('#todo_template').html());
// //   // gets todoTemplate stored in DOM.
// //   var $todo = $(todoTemplate);
// //   // Creates an jQueryDOMElement from the todoTemplate.
// //   $todo.find('h2').text(todoName.todo_content);
// //   $todo.find('.delete').attr("href", "/delete/" + todoName.id)
// //        .on('click', removeTodo)
// //   $todo.find('.complete').attr("href", "/complete/" + todoName.id)
// //        .on('click', completeTodo)
// //   // Modifies it's text to use the passed in todoName.
// //   return $todo;
// //   // Returns the jQueryDOMElement to be used elsewhere.
// // }
