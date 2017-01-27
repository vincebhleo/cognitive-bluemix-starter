$(document).ready(function() {
  $('.dropdown-menu').on( 'click', 'a', function() {    
    if ($(this).html() == "Node.js") {
      $('input:radio[id=nodeJs]').prop('checked', true);
    } else {
      $('input:radio[id=nodeRed]').prop('checked', true);
    }
    $('#platformDropdown').html($(this).html() + '<span class="caret"></span>');
  });

  //var isConnecting = false;
  var self = this;
  var stream = null;
	//$('#messages').append($('<li>').text(""));
  
  var audioElement = null;

  $( "#node-red-label" ).click(function() {
    window.open('https://' + window.location.hostname + "/red", '_blank');
  });
  
	$chatInput = $('#chat-input');
	$loader = $('.loader');
	$micButton = $('.chat-window--microphone-button');

  var isNodeJs = function() {
    return 'nodeJs' == $("input[name=platform]:checked").val();
  };
  
  var isNodeRed = function() {
    return 'nodeRed' == $("input[name=platform]:checked").val();
  };
  
  var converseUrl = function() {
    if (isNodeJs()) {
      return '/conversejs';
    } else {
      return '/conversered';
    }
  };

  
  function sendRequest() {
    if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(onGotWeatherSuccess, onGotWeatherFailed);   
    } else {
      alert('Geolocation is not supported by this browser.');
    }    
  }
  
  function onGotWeatherSuccess(position) {   
    var params = 'lat=' + position.coords.latitude + '&long=' + position.coords.longitude;
    var payload = {};
    
    payload.lat = position.coords.latitude;
    payload.long = position.coords.longitude;
    payload.text = $('#chat-input').val();
    
    console.log(payload);
    converse($('#chat-input').val(), payload);   
  };
  
  function onGotWeatherFailed(err) {   
    alert('Error getting weather ' + err);     
  };
  
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

  function text2Speech(data) {
    getTTSToken.then(function(token) {
					WatsonSpeech.TextToSpeech.synthesize({
					 text: data,
					 token: token
				 });

			 });
  }
  
  $micButton.mousedown(function() {  
    $micButton.removeClass('normal').addClass('active');
    if (isNodeJs()) {
      record();
    } else {
    } 
    
  });
    
  $micButton.mouseup(function() { 
  $micButton.addClass('normal');
    if (isNodeJs()) {
      stopRecording();
    } else {
    }
  });
    
	$loader.hide();
//	var person = prompt("Please enter your name", "Jack Simons");
	 $('#messages').append($('<li>').text("Hello I am Watson, How may I help?"));
//	TTS('Hello I am Watson, How may I help?');

	$chatInput.focus();
	$chatInput.keyup(function(event){
		if(event.keyCode === 13) {
      sendRequest();
		}
	});
  
  var converse = function(userText, payload){
			$(".chat").animate({ scrollTop: $(document).height() }, "slow");
			$loader.css('visibility','visible');
			$loader.show();
			var msg = $('#chat-input').val();
			console.log("payload : " + payload);
			$('#messages').append($('<li>').text(msg));
      $("div").animate({scrollTop: $('ul#messages li:last').offset().top + 1000});
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
          
          if (audioElement) {
            audioElement.pause();
            if ((audioElement.currentTime !== 0) &&
                (audioElement.currentTime > 0 && audioElement.currentTime < audioElement.duration)) {
                  audioElement.currentTime = 0;
            }
            audioElement = null;
          }

					getTTSToken.then(function(token) {
					  audioElement = WatsonSpeech.TextToSpeech.synthesize({
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
	};
		
  
});
