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
                updateCharts();
                updateDash();
                reloadSelect2();
                reloadFile_Upload();
                reloadTypeahead();
                dash();
                if(url == 'static/pages/CControl/complaint_control.html')
                initializeComplaintControlPage();
            } else {
                console.error('Failed to load content: ' + xhr.status);
            }
        }
    };
    xhr.open('GET', url, true);
    xhr.send();
    setActiveNavItem(url);
}
function setActiveNavItem(url) {
  // Reset active state for all nav items
  var navItems = document.querySelectorAll('.nav-item');
  navItems.forEach(function(item) {
      item.classList.remove('active');
  });

  // Determine which nav item corresponds to the loaded content URL
  var navLinks = document.querySelectorAll('.nav-link');
  navLinks.forEach(function(link) {
      var onClickAttribute = link.getAttribute('onclick');
      if (onClickAttribute && onClickAttribute.includes(url)) {
          link.parentElement.classList.add('active');
      }
  });
}


function updateContent(x,y) {
  // Fetch data from the server
  fetch(x)
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.text();
    })
    .then(data => {
      // Update the content of the div container with the fetched data
      document.getElementById(y).innerHTML = data;
    })
    .catch(error => {
      console.error('There was a problem with the fetch operation:', error);
    });
}