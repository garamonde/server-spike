Garamonde = function() {
  var accessToken = {
    store: function(value) {
      $.cookie("access_token", value)
    },
    get: function() {
      return $.cookie("access_token")
    }
  }

  var AuthScreen = function() { return $("#auth-option") }
  var GameScreen = function() { return $("#interface") }

  showScreens = function() {
    if(accessToken.get() == null) {
      GameScreen().hide()
      AuthScreen().show()
    } else {
      AuthScreen().hide()
      GameScreen().show()
    }
  }

  var logIn = function(code) {
    $.post("/users/sessions", { auth_code: code }, "json")
     .done(function(data) {
       data = JSON.parse(data)
       accessToken.store(data.session.token)
       showScreens()
     })
  }

  // Sign-Up Form: Submit
  $(document).on("submit", "#sign-up form", function(event) {
    event.preventDefault()

    var form = $("#sign-up form")
    $.post(form.attr("action"), form.serialize(), "json")
     .done(function(data) {
       data = JSON.parse(data)
       logIn(data.user.auth_code)
     })
  })

  // Log-In Form: Submit
  $(document).on("submit", "#log-in form", function(event) {
    event.preventDefault()
    
    var code = $("#log-in form input:first").val()
    logIn(code);
  })

  $(document).ready(function() {
    showScreens()
  })

  return {
    showScreens: showScreens
  }
}()
