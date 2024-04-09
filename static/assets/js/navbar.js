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
function showSearchResults(searchResults) {
  const searchResultsContainer = document.getElementById('search-results');
  searchResultsContainer.innerHTML = '';

  if (searchResults.length > 0) {
    searchResultsContainer.classList.add('search-results-show');

    searchResults.forEach(result => {
      const resultElement = document.createElement('div');
      resultElement.classList.add('search-result');

      const iconElement = document.createElement('i');
      iconElement.classList.add('mdi', 'mdi-file-document');

      const fileLabelSpan = document.createElement('span');
      fileLabelSpan.textContent = result.label;

      resultElement.appendChild(iconElement);
      resultElement.appendChild(fileLabelSpan);

      resultElement.addEventListener('click', () => {
        loadContent(result.filePath, 'main_body');
        hideSearchResults();
      });

      searchResultsContainer.appendChild(resultElement);
    });

    searchResultsContainer.style.display = 'block';
  } else {
    hideSearchResults();
  }
}

function hideSearchResults() {
  const searchResultsContainer = document.getElementById('search-results');
  searchResultsContainer.classList.remove('search-results-show');
  setTimeout(() => {
    searchResultsContainer.style.display = 'none';
  }, 300);
}

function searchContent(searchInputElement) {
  const searchTerm = searchInputElement.value.toLowerCase().trim();
  const searchResults = [];

  for (const filePath in fileContents) {
    const fileContent = fileContents[filePath].toLowerCase();
    const fileLabel = fileLabels[filePath].toLowerCase();

    if (fileContent.includes(searchTerm) || fileLabel.includes(searchTerm)) {
      searchResults.push({ filePath, label: fileLabels[filePath], content: fileContents[filePath] });
    } else {
      const words = searchTerm.split(/\s+/);
      if (words.every(word => fileContent.includes(word) || fileLabel.includes(word))) {
        searchResults.push({ filePath, label: fileLabels[filePath], content: fileContents[filePath] });
      }
    }
  }

  searchResults.sort((a, b) => {
    const aMatches = (a.content.match(new RegExp(searchTerm, 'g')) || []).length + (a.label.match(new RegExp(searchTerm, 'g')) || []).length;
    const bMatches = (b.content.match(new RegExp(searchTerm, 'g')) || []).length + (b.label.match(new RegExp(searchTerm, 'g')) || []).length;
    return bMatches - aMatches;
  });

  showSearchResults(searchResults);
}