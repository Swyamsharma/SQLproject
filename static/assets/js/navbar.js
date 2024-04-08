const fileContents = {
    'static/pages/library/libstock.html': '',
    'static/pages/library/books.html': '',
    'static/pages/library/members.html': '',
    'static/pages/attendance/att.html': '',
    'static/pages/CControl/complaint_control.html': '',
    'static/pages/news/news.html': '',
    'static/pages/reports/reports.html': '',
    'static/pages/dash/dash.html': ''
};

const fileLabels = {
    'static/pages/library/libstock.html': 'Library - Stock',
    'static/pages/library/books.html': 'Library - Books',
    'static/pages/library/members.html': 'Library - Members',
    'static/pages/attendance/att.html': 'Attendance',
    'static/pages/CControl/complaint_control.html': 'Complaint Control',
    'static/pages/news/news.html': 'News',
    'static/pages/reports/reports.html': 'Reports',
    'static/pages/dash/dash.html': 'Dashboard'
};

// Preload all the HTML files
for (const filePath in fileContents) {
    fetch(filePath)
        .then(response => response.text())
        .then(data => {
            fileContents[filePath] = data;
        })
        .catch(error => console.error(error));
}

window.addEventListener('DOMContentLoaded', initSearchFunctionality);

function initSearchFunctionality() {
    const searchInput = document.querySelector('.search input');
    searchInput.addEventListener('input', () => searchContent(searchInput));
    searchInput.addEventListener('keyup', handleKeyPress);

    // Add event listener to the document for click events
    document.addEventListener('click', function(event) {
        const searchResultsContainer = document.getElementById('search-results');

        // Check if the click target is not the search input or search results container
        if (event.target !== searchInput && !searchResultsContainer.contains(event.target)) {
            searchResultsContainer.style.display = 'none'; // Hide search results
        }
    });
}

function handleKeyPress(event) {
    if (event.key === 'Enter') {
        searchContent(event.target);
    }
}

function searchContent(searchInputElement) {
    console.log("searching");

    const searchTerm = searchInputElement.value.toLowerCase();
    const searchResults = [];

    for (const filePath in fileContents) {
        const fileContent = fileContents[filePath];
        if (fileContent.toLowerCase().includes(searchTerm)) {
            searchResults.push({ filePath, label: fileLabels[filePath], content: fileContent });
        }
    }

    const searchResultsContainer = document.getElementById('search-results');
    console.log(searchResultsContainer);

    if (searchResultsContainer) {
        searchResultsContainer.innerHTML = '';

        if (searchResults.length > 0) {
            searchResults.forEach(result => {
                const resultElement = document.createElement('div');
                resultElement.classList.add('search-result');
                
                // Create icon element
                const iconElement = document.createElement('i');
                iconElement.classList.add('mdi', 'mdi-file-document');
                
                // Create span for displaying file label
                const fileLabelSpan = document.createElement('span');
                fileLabelSpan.textContent = result.label;
                
                // Append icon and file label span to result element
                resultElement.appendChild(iconElement);
                resultElement.appendChild(fileLabelSpan);
                
                resultElement.addEventListener('click', () => {
                    loadContent(result.filePath, 'main_body');
                    searchResultsContainer.style.display = 'none'; // Hide search results after click
                });

                searchResultsContainer.appendChild(resultElement);
            });

            searchResultsContainer.style.display = 'block'; // Show search results if there are results
        } else {
            searchResultsContainer.style.display = 'none'; // Hide search results if no results found
        }
    } else {
        console.error('search-results container not found');
    }
}
