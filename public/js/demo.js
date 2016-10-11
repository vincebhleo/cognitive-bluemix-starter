$(document).ready(function() {

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
      WatsonSpeech.SpeechToText.recognizeMicrophone({
        token: token,
        continuous: false,
        outputElement: $chatInput[0],
        keepMicrophone: navigator.userAgent.indexOf('Firefox') > 0
      }).promise().then(function() {
				$micButton.addClass('chat-window--microphone-button');
        converse($chatInput.val());
      })
      .then(deactivateMicButton)
      .catch(deactivateMicButton);
    });
  }

	$micButton.click(record);

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
