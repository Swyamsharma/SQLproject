document.addEventListener("DOMContentLoaded", function() {
    // Get all nav items
    var navItems = document.querySelectorAll('.nav-item');

    // Function to handle button click
    function handleButtonClick() {
        // Remove 'active' class from all nav items
        navItems.forEach(function(item) {
            item.classList.remove('active');
        });

        // Add 'active' class to the clicked nav item
        this.classList.add('active');

        // Execute your function here
        // For example, if you want to execute a function named 'myFunction' when a button is clicked
        // myFunction();
    }

    // Add click event listener to each nav item
    navItems.forEach(function(item) {
        item.addEventListener('click', handleButtonClick);
    });
});
