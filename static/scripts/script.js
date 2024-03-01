// function sendData() { 
//     var userInput = document.getElementById("input-text").value;
//     if (userInput == '') { return; }
//     var chatMessages = document.getElementById("chat-messages");
//     chatMessages.innerHTML += '<div class="message-wrapper reverse"><img class="message-pp" src="/static/portfolio-1.png" alt="profile-pic"><div class="message-box-wrapper"><div class="message-box">' + userInput + '&nbsp;&nbsp;&nbsp;</div><span>You</span></div></div>';
//     document.getElementById("input-text").value = '';
//     chatMessages.scrollTop = chatMessages.scrollHeight;
//     flag=false;
//     $.ajax({ 
//         url: '/chat', 
//         type: 'POST',
//         data: { 'data': userInput },
//         success: function(response) {
//             chatMessages.innerHTML += '<div class="message-wrapper"><img class="message-pp" src="/static/favicon.ico" alt="profile-pic"><div class="message-box-wrapper"><div class="message-box">' + response + '&nbsp;&nbsp;&nbsp;</div><span>Bot</span></div></div>';
//             flag=true;
//             chatMessages.scrollTop = chatMessages.scrollHeight;
//                         }, 
//         error: function(error) { 
//             console.log(error); 
//             } 
//         }
//     );
    

// }

$(document).ready(function(){
    var chatMessages = $('#chat-messages');
    var messageInput = $('#message-input');
    var sendButton = $('#send-button');

    function appendMessage(message) {
        chatMessages.append('<div>' + message + '</div>');
        chatMessages.scrollTop(chatMessages[0].scrollHeight);
    }

    function sendMessage() {
        var message = messageInput.val();
        //print(message);
        if (message.trim() !== '') {
            $.ajax({
                url: '/chat',
                type: 'POST',
                data: { 'data': message },
                success: function(response) {
                    appendMessage('You: ' + message);
                    appendMessage('Bot: ' + response);
                },
                error: function(xhr, status, error) {
                    console.error('Error sending message:', error);
                }
            });
            messageInput.val('');
        }
    }

    sendButton.on('click', function() {
        sendMessage();
    });

    messageInput.keypress(function(event) {
        if (event.which === 13) {
            sendMessage();
        }
    });
});

