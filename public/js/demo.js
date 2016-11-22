$(document).ready(function() {
  
  //var isConnecting = false;
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
			$micButton.addClass('active');
       stream = WatsonSpeech.SpeechToText.recognizeMicrophone({
        token: token,
        continuous: false,
        outputElement: $chatInput[0],
        content_type: 'audio/wav',
        keepMicrophone: navigator.userAgent.indexOf('Firefox') > 0
      });
      
      stream.promise().then(function() {
        $micButton.addClass('chat-window--microphone-button');
        console.log('Microphone opened');				
        $micButton.addClass('normal');
        converse($chatInput.val());
      })
      .then(function(error){
        $micButton.addClass('normal');
        console.log('Microphone closed');        
        deactivateMicButton;
      })
      .catch(function(error){
        $micButton.addClass('normal');
        console.log('catch micrphone');
        deactivateMicButton;
      })
    });    
    
  }

  function stopRecording() {      
    $micButton.addClass('normal');
    if (stream) {
      try {
      stream.stop;
        //setTimeout(stream.stop, 500);
      } catch (err) {       
        console.log("Error in stopRecording() " + err);
      }
    }
  }

  $micButton.mousedown(function() {  
    $micButton.removeClass('normal').addClass('active');
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

			$.post({
				url: converseUrl(),
				data: payload,
        dataType: 'json',
				success: function(data) {
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
        },
        error: function(err) {
          console.log(JSON.stringify(err));
          $loader.hide();
        }                 
      });
	}
});
