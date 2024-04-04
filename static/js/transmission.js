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


  function fetchtable(x, y) {
    var query = y;
    $(x).html('');
  
    $.post('/querylib', { query: query }, function (response) {
      var result = response.result;
  
      if (result && result.length > 0) {
        var table = $('<table class="table table-bordered table-contextual">').appendTo('#query-result');
        var thead = $('<thead>').appendTo(table);
        var theadTr = $('<tr>').appendTo(thead);
  
        // Create table headers
        Object.keys(result[0]).forEach(function (key) {
          $('<th>').text(key).appendTo(theadTr);
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
            } else {
              return { data: key };
            }
          }),
          pageLength: 20,
          order: [],
          language: {
            emptyTable: "No results found."
          },
          createdRow: function (row, data, dataIndex) {
            if (data.available === 1) {
              $(row).addClass('table-success');
            } else {
              $(row).addClass('table-danger');
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
