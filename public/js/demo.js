$(document).ready(function() {
  
  var self = this;
  var stream = null;
	$('#messages').append($('<li>').text(""));

	$chatInput = $('#chat-input');
	$loader = $('.loader');
	$micButton = $('.chat-window--microphone-button');

	var getSTTToken = $.ajax('/api/speech-to-text/token');
 	var getTTSToken = $.ajax('/api/text-to-speech/token');

	var deactivateMicButton = $micButton.removeClass.bind($micButton, 'active');

  function record() {
  
    getSTTToken.then(function(token) {
			//$micButton.css('background-color','red');
			$micButton.addClass('active');
      stream = WatsonSpeech.SpeechToText.recognizeMicrophone({
        token: token,
        continuous: false,
        outputElement: $chatInput[0],
        content_type: 'audio/wav',
        keepMicrophone: navigator.userAgent.indexOf('Firefox') > 0
      });
      
      stream.promise().then(function() {
        console.log('opened micrphone');
				$micButton.addClass('chat-window--microphone-button');
        converse($chatInput.val());
      })
      .then(function(error){console.log('error micrphone');deactivateMicButton;})
      .catch(function(error){console.log('catch micrphone');deactivateMicButton;})
    });
    
    /*self.stream.on('error', function(err) {
            console.log("we are in error function: i.e. error is produced when calling STT");
            console.log(err);
        });*/
  }

  function stopRecording() {  
  $micButton.addClass('normal');
    if (stream) {
                try {
                    //console.log("we are in try block ");
                    setTimeout(stream.stop, 500);
                } catch (err) {
                    console.log("error produced while stoping a stream");
                    console.log(err);
                }
            }
  }
  //$micButton.click(record);

  $micButton.mousedown(function() {        
    record();      
  });
    
  $micButton.mouseup(function() {        
    stopRecording();
  });
    
	$loader.hide();
//	var person = prompt("Please enter your name", "Jack Simons");
	 $('#messages').append($('<li>').text("Hello I am Watson, How may I help?"));
//	TTS('Hello I am Watson, How may I help?');

	$chatInput.focus();
	$chatInput.keyup(function(event){
		if(event.keyCode === 13) {
			converse($(this).val());
		}
	});
		var converse = function(userText){
			$(".chat").animate({ scrollTop: $(document).height() }, "slow");
			$loader.css('visibility','visible');
			$loader.show();
			var msg = $('#chat-input').val();
			console.log(msg);
			$('#messages').append($('<li>').text(msg));
			$('#chat-input').val('');

			$.get({
				url : '/conversation',
				data : {
					text : msg
				},
				success : function(data) {
					console.log(data);
					var reply  = data;
					//reply.replace(","," ");
					console.log(reply);

					$('#messages').append($('<li>').text(reply));
					$loader.hide();
					$(".chat").animate({ scrollTop: $(document).height() }, "slow");

					getTTSToken.then(function(token) {
					WatsonSpeech.TextToSpeech.synthesize({
					 text: data,
					 token: token
				 });

			 });
			}
		});
	}
});
