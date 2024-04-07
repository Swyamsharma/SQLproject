function sendMessage() {
  var message = $('#message').val();
  $.post('/chat', { data: message }, function (response) {
    $('#chat-box').append('<p><strong>You:</strong> ' + message + '</p>');
    $('#chat-box').append('<p><strong>Bot:</strong> ' + response.response + '</p>');
  });
  $('#message').val('');
}

function sendQuery() {
  var query = $('#query-text').val();
  $.post('/query', { query: query }, function (response) {
    var result = response.result;
    if (result && result.length > 0) {
      var table = '<table border="1">';
      // Create table headers
      table += '<tr>';
      for (var header in result[0]) {
        table += '<th>' + header + '</th>';
      }
      table += '</tr>';
      // Populate table with data
      result.forEach(function (row) {
        table += '<tr>';
        for (var key in row) {
          table += '<td>' + row[key] + '</td>';
        }
        table += '</tr>';
      });
      table += '</table>';
      $('#query-result').html(table);
    } else {
      $('#query-result').html('<p>No results found.</p>');
    }
  });
  $('#query-text').val('');
}
function librarytable() {
  var query = 'select * from books';
  $.post('/querylib', { query: query }, function (response) {
    var result = response.result;

    if (result && result.length > 0) {
      var table = '<table class="table table-bordered table-contextual">';

      // Create table headers
      table += '<thead><tr>';
      for (var header in result[0]) {
        table += '<th>' + header + '</th>';
      }
      table += '</tr></thead>';

      // Populate table with data
      table += '<tbody>';
      result.forEach(function (row, index) {
        var rowClass = '';
        if (row.available === 1) {
          rowClass = 'table-success';
        }
        if (row.available === 0) {
          rowClass = 'table-danger';
        }
        table += '<tr class="' + rowClass + '">';
        for (var key in row) {
          table += '<td>' + row[key] + '</td>';
        }
        table += '</tr>';
      });
      table += '</tbody>';
      table += '</table>';

      $('#librarybooks').html(table);
    } else {
      $('#librarybooks').html('<p>No results found.</p>');
    }
  });

  $('#query-text').val('');
}


function fetchtable(x, y, z) {
  var query = y;
  $(x).html('');

  $.post('/querylib', { query: query }, function (response) {
    var result = response.result;

    if (result && result.length > 0) {
      var table = $('<table class="' + z + '">').appendTo('#query-result');
      var thead = $('<thead>').appendTo(table);
      var theadTr = $('<tr>').appendTo(thead);

      // Create table headers
      Object.keys(result[0]).forEach(function (key) {
        $('<th>').text(key).appendTo(theadTr);
      });

      // Identify the date columns
      var dateColumns = Object.keys(result[0]).filter(function (key) {
        return key.includes('date');
      });

      table.DataTable({
        data: result,
        columns: Object.keys(result[0]).map(function (key) {
          if (key === 'available') {
            return {
              data: 'available',
              render: function (data, type, row) {
                return data === 1 ? 'Yes' : 'No';
              }
            };
          } else if (dateColumns.includes(key)) {
            return {
              data: key,
              render: function (data, type, row) {
                if (type === 'display' && data !== null) {
                  var date = new Date(data);
                  return date.toLocaleString();
                } else if (type === 'sort' && data !== null) {
                  var date = new Date(data);
                  return date.getFullYear() + '-' + ('0' + (date.getMonth() + 1)).slice(-2) + '-' + ('0' + date.getDate()).slice(-2) + ' ' + ('0' + date.getHours()).slice(-2) + ':' + ('0' + date.getMinutes()).slice(-2) + ':' + ('0' + date.getSeconds()).slice(-2);
                } else {
                  return data;
                }
              }
            };
          } else {
            return { data: key };
          }
        }),
        pageLength: 10,
        order: [],
        language: {
          emptyTable: "No results found."
        },
        createdRow: function (row, data, dataIndex) {
          if (y == 'select * from books') {
            if (data.available === 1) {
              $(row).addClass('table-success');
            } else {
              $(row).addClass('table-danger');
            }
          }
          else if (y == 'SELECT borrowings.*, members.contact FROM borrowings JOIN members ON borrowings.member_id = members.member_id') {
            var currentDate = new Date();
            var dueDate = new Date(data.due_date);
            console.log(currentDate);
            console.log(dueDate);
            if (data.returned_date !== null) {
              $(row).addClass('table-success');
            } else if (dueDate < currentDate) {
              $(row).addClass('table-danger');
            }
            else $(row).addClass('table-dark');
          } else {
            $(row).addClass('table-dark');
          }
        }
      });
    } else {
      $(x).html('<p>No results found.</p>');
    }
  });
}
function handleKeyPress(event, funcName) {
  if (event.keyCode === 13) {
    event.preventDefault();
    if (funcName === 'sendMessage') {
      sendMessage();
    } else if (funcName === 'sendQuery') {
      sendQuery();
    }
  }
}


function borrowBook() {
  const bookId = document.getElementById('book-id').value;
  const memberId = document.getElementById('member-id').value;
  const interval = document.getElementById('loan-interval').value;

  // Check if the input fields are not empty
  if (!bookId || !memberId || !interval) {
    $('#borrow-result').html('<p class="text-danger">Please enter both book ID, member ID, and interval.</p>');
    return;
  }

  // Prepare the SQL query
  const query = `SELECT borrow_book(${bookId}, ${memberId}, ${interval})`;
  console.log(query);

  // Send the query to the server
  $.post('/querylib', { query: query }, function (response) {
    const result = response.result;
    console.log(result);

    if (result && result.length > 0) {
      const borrowResult = result[0]['borrow_book' + '(' + bookId + ', ' + memberId + ', ' + interval + ')'];

      if (borrowResult.includes('borrowed')) {
        $('#borrow-result').html(`<p class="text-success">${borrowResult}</p>`);
        fetchtable('#query-result', 'select * from borrowings', 'table table-bordered table-contextual')
      } else {
        $('#borrow-result').html(`<p class="text-danger">${borrowResult}</p>`);
      }
    } else {
      $('#borrow-result').html('<p class="text-danger">Failed to borrow book.</p>');
    }
  });
}

function returnBook() {
  const bookId = document.getElementById('rbook-id').value;
  const memberId = document.getElementById('rmember-id').value;

  // Check if the input fields are not empty
  if (!bookId || !memberId) {
    $('#return-result').html('<p class="text-danger">Please enter both book ID and member ID.</p>');
    return;
  }

  // Prepare the SQL query
  const query = `SELECT return_book(${bookId}, ${memberId})`;
  console.log(query);

  // Send the query to the server
  $.post('/querylib', { query: query }, function (response) {
    const result = response.result;
    console.log(result);

    if (result && result.length > 0) {
      const returnResult = result[0]['return_book(' + bookId + ', ' + memberId + ')'];

      if (returnResult.includes('returned')) {
        $('#return-result').html(`<p class="text-success">${returnResult}</p>`);
        fetchtable('#query-result', 'select * from borrowings', 'table table-bordered table-contextual')
      } else {
        $('#return-result').html(`<p class="text-danger">${returnResult}</p>`);
      }
    } else {
      $('#return-result').html('<p class="text-danger">Failed to return book.</p>');
    }
  });
}

function addBook() {
  const title = document.getElementById('title_b').value;
  const author = document.getElementById('author_b').value;
  const isbn = document.getElementById('isbn_t').value;
  const genre = document.getElementById('genre_t').value;
  const publisher = document.getElementById('pub_t').value;

  // Check if the input fields are not empty
  if (!title || !author || !isbn || !genre || !publisher) {
    $('#borrow-result').html('<p class="text-danger">Please fill in all the fields.</p>');
    return;
  }

  // Prepare the SQL query
  const query = `SELECT add_book('${title}', '${author}', '${publisher}', '${isbn}', '${genre}')`;
  console.log(query);

  // Send the query to the server
  $.post('/querylib', { query: query }, function (response) {
    const result = response.result;
    console.log(result);

    if (result && result.length > 0) {
      const addResult = result[0]['add_book(\'' + title + '\', \'' + author + '\', \'' + publisher + '\', \'' + isbn + '\', \'' + genre + '\')'];

      if (addResult.includes('added')) {
        $('#borrow-result').html(`<p class="text-success">${addResult}</p>`);
        fetchtable('#query-result', 'select * from books', 'table table-bordered table-contextual');
      } else {
        $('#borrow-result').html(`<p class="text-danger">${addResult}</p>`);
      }
    } else {
      $('#borrow-result').html('<p class="text-danger">Failed to add book.</p>');
    }
  });
}

function removeBook() {
  const bookId = document.getElementById('bookid_rem').value;

  // Check if the input field is not empty
  if (!bookId) {
    $('#return-result').html('<p class="text-danger">Please enter the book ID.</p>');
    return;
  }

  // Prepare the SQL query
  const query = `SELECT remove_book(${bookId})`;
  console.log(query);

  // Send the query to the server
  $.post('/querylib', { query: query }, function (response) {
    const result = response.result;
    console.log(result);

    if (result && result.length > 0) {
      const removeResult = result[0]['remove_book(' + bookId + ')'];

      if (removeResult.includes('removed')) {
        $('#return-result').html(`<p class="text-success">${removeResult}</p>`);
        fetchtable('#query-result', 'select * from books', 'table table-bordered table-contextual');
      } else {
        $('#return-result').html(`<p class="text-danger">${removeResult}</p>`);
      }
    } else {
      $('#return-result').html('<p class="text-danger">Failed to remove book.</p>');
    }
  });
}

function addMember() {
  const name = document.getElementById('member_name').value;
  const email = document.getElementById('member_email').value;

  // Check if the input fields are not empty
  if (!name || !email) {
    $('#add-member-result').html('<p class="text-danger">Please fill in all the fields.</p>');
    return;
  }

  // Prepare the SQL query
  const query = `SELECT add_member('${name}', '${email}')`;

  // Send the query to the server
  $.post('/querylib', { query: query }, function (response) {
    const result = response.result;

    if (result && result.length > 0) {
      const addResult = result[0]['add_member(\'' + name + '\', \'' + email + '\')'];

      if (addResult.includes('added')) {
        $('#add-member-result').html(`<p class="text-success">${addResult}</p>`);
      } else {
        $('#add-member-result').html(`<p class="text-danger">${addResult}</p>`);
      }
    } else {
      $('#add-member-result').html('<p class="text-danger">Failed to add member.</p>');
    }
  });
}

function removeMember() {
  const memberId = document.getElementById('member_id_remove').value;

  // Check if the input field is not empty
  if (!memberId) {
    $('#remove-member-result').html('<p class="text-danger">Please enter the member ID.</p>');
    return;
  }

  // Prepare the SQL query
  const query = `SELECT remove_member(${memberId})`;

  // Send the query to the server
  $.post('/querylib', { query: query }, function (response) {
    const result = response.result;

    if (result && result.length > 0) {
      const removeResult = result[0]['remove_member(' + memberId + ')'];

      if (removeResult.includes('removed')) {
        $('#remove-member-result').html(`<p class="text-success">${removeResult}</p>`);
      } else {
        $('#remove-member-result').html(`<p class="text-danger">${removeResult}</p>`);
      }
    } else {
      $('#remove-member-result').html('<p class="text-danger">Failed to remove member.</p>');
    }
  });
}

function createOpenAttendance() {
  var subjectName = $('#subject-name').val();
  if (!subjectName) {
    $('#attendance-result').html('<p class="text-danger">Please enter the subject name.</p>');
    return;
  }
  // Prepare the query
  var query = "SELECT create_attendance_func('" + subjectName + "') AS result";

  // Send the query to the server
  $.post('/queryatt', { query: query }, function (response) {
    if (response) {
      console.log(response);
      $('#subject-name').val('');
      $('#attendance-result').html('<p class="text-success">'+response.result[0].result+'</p>');
      alert(response.result[0].result);
      // Redirect or perform any other action as needed
    } else {
      alert("Failed to create open attendance.");
    }
  });
}
function removeAttendance() {
  var attendanceId = $('#attendance-id').val();
  if (!attendanceId) {
    $('#aid-result').html('<p class="text-danger">Please enter the attendance ID.</p>');
    return;
  }
  // Prepare the query
  var query = "SELECT clear_attendance_records_and_return_status(" + attendanceId + ") AS result";

  // Send the query to the server
  $.post('/queryatt', { query: query }, function(response) {
      if (response) {
          $('#attendance-id').val('');
          $('#aid-result').html('<p class="text-success">'+response.result[0].result+'</p>');
      }
  });
}


function formatTime(date) {
  var hours = date.getHours();
  var minutes = date.getMinutes();
  var seconds = date.getSeconds();
  return padZero(hours) + ":" + padZero(minutes) + ":" + padZero(seconds);
}

function padZero(num) {
  return num < 10 ? '0' + num : num;
}
function fetchatt(x, y, z) {
  var query = y;
  $(x).html('');

  $.post('/queryatt', { query: query }, function (response) {
    var result = response.result;

    if (result && result.length > 0) {
      var table = $('<table class="' + z + '">').appendTo('#query-result');
      var thead = $('<thead>').appendTo(table);
      var theadTr = $('<tr>').appendTo(thead);

      // Create table headers
      Object.keys(result[0]).forEach(function (key) {
        $('<th>').text(key).appendTo(theadTr);
      });

      // Identify the date columns
      var dateColumns = Object.keys(result[0]).filter(function (key) {
        return key.includes('date');
      });

      table.DataTable({
        data: result,
        columns: Object.keys(result[0]).map(function (key) {
          if (key === 'available') {
            return {
              data: 'available',
              render: function (data, type, row) {
                return data === 1 ? 'Yes' : 'No';
              }
            };
          } else if (dateColumns.includes(key)) {
            return {
              data: key,
              render: function (data, type, row) {
                if (type === 'display' && data !== null) {
                  var date = new Date(data);
                  return date.toLocaleString();
                } else if (type === 'sort' && data !== null) {
                  var date = new Date(data);
                  return date.getFullYear() + '-' + ('0' + (date.getMonth() + 1)).slice(-2) + '-' + ('0' + date.getDate()).slice(-2) + ' ' + ('0' + date.getHours()).slice(-2) + ':' + ('0' + date.getMinutes()).slice(-2) + ':' + ('0' + date.getSeconds()).slice(-2);
                } else {
                  return data;
                }
              }
            };
          } else {
            return { data: key };
          }
        }),
        pageLength: 10,
        order: [],
        language: {
          emptyTable: "No results found."
        },
        createdRow: function (row, data, dataIndex) {
          if (y == 'select * from books') {
            if (data.available === 1) {
              $(row).addClass('table-success');
            } else {
              $(row).addClass('table-danger');
            }
          }
          else if (y == 'SELECT borrowings.*, members.contact FROM borrowings JOIN members ON borrowings.member_id = members.member_id') {
            var currentDate = new Date();
            var dueDate = new Date(data.due_date);
            console.log(currentDate);
            console.log(dueDate);
            if (data.returned_date !== null) {
              $(row).addClass('table-success');
            } else if (dueDate < currentDate) {
              $(row).addClass('table-danger');
            }
            else $(row).addClass('table-dark');
          } else {
            $(row).addClass('table-dark');
          }
        }
      });
    } else {
      $(x).html('<p>No results found.</p>');
    }
  });
}
