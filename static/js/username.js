// Function to fetch username and display it in the username-container div
document.addEventListener("DOMContentLoaded", function () {
  var xhr = new XMLHttpRequest();
  xhr.open("GET", "/get_username", true);
  xhr.onreadystatechange = function () {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      if (xhr.status === 200) {
        var data = JSON.parse(xhr.responseText);
        document.getElementById("username-container").textContent =
          "Welcome, " + data.username + " !";
      } else {
        document.getElementById("username-container").textContent =
          "Username not found.";
      }
    }
  };
  xhr.send();
});


function loadContent(url, targetId) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function () {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                document.getElementById(targetId).innerHTML = xhr.responseText;
            } else {
                console.error('Failed to load content: ' + xhr.status);
            }
        }
    };
    xhr.open('GET', url, true);
    xhr.send();
}
