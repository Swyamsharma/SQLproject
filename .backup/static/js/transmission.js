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
