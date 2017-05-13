
$( document ).ready(function(){
  $('.alert-notice').fadeOut(4000);
});

function setBoard(){
  var url = window.location.href;

  // refreshes the board
  $.get(url + "/pieces").success(function(data){
    for(var x = 1; x <= 8; x++) {
      for (var y = 1; y <= 8; y++) {
        var square = $('#' + x + y);
        square.html('');
      }
    }

    // puts pieces on the board
    data.forEach(function(piece){
      var cssSelector = "#" + piece.x_position + piece.y_position;
      var square = $(cssSelector);
      console.log(square);

      var chess_piece = $('<div></div>');
      chess_piece.html(piece.unicode);
      chess_piece.addClass('piece');
      chess_piece.attr('data-id', piece.id);
      chess_piece.attr('data-x-position', piece.x_position);
      chess_piece.attr('data-y-position', piece.y_position);

      square.html('');
      square.html(chess_piece);
    });

    dragDropPiece();
  });
}

function handleDrag(event, ui){
  var chess_piece = $(ui.draggable);
  var square = $(this);

  var piece_id = chess_piece.attr('data-id');
  var dx = square.attr('data-x');
  var dy = square.attr('data-y');

  var url = window.location.href + '/pieces/' + piece_id;
  var dataViewUrl = window.location.href + '/data_view/';

  $.ajax({
    url: url,
    type: 'PUT',
    data: { piece: { x_position: dx, y_position: dy, id: piece_id }, _method: 'patch' },
    success: function(data){
      showMove();
      $.get(dataViewUrl).success(function(data){
        showTurn();
        $('.turn').html(data.player_turn);
      });
    }
  });
}

function dragDropPiece(){
  $('.piece').draggable({
    containment: ".chessboard",
    snap: ".square",
    snapMode: 'inner',
    snapTolerance: 40
    //revert: true
  });
  $('.square').droppable({
    drop: handleDrag
    // add revert false for when the drop is valid
  });
}

function getPath() {
  var pathArray = window.location.pathname.split( '/' );
  var gameId = pathArray[pathArray.length -1]
  return gameId;
}

function showMove() {
  // Enable pusher logging - don't include this in production
  var environment = $('body').data('rails-env');
  if (environment != 'production') {
  Pusher.logToConsole = true;
  }

  var pusher = new Pusher('85619837e880f6d5568c', {
    encrypted: true
  });

  var number = getPath();

  var channel = pusher.subscribe("game-channel-" + number);
  channel.bind('piece-moved', function(data) {
  setBoard();
  });
}

function showTurn(){
  var environment = $('body').data('rails-env');
  if (environment != 'production') {
  Pusher.logToConsole = true;
  }

  var pusher = new Pusher('85619837e880f6d5568c', {
    encrypted: true
  });

  var number = getPath();

  var channel = pusher.subscribe("turn-channel-" + number);
  channel.bind('next-turn', function(data) {
    // $('.turn').html(data.player_turn);
    setBoard();
  });
}

function newPlayer(){
  var environment = $('body').data('rails-env');
  if (environment != 'production') {
    Pusher.logToConsole = true;
  }

  var pusher = new Pusher('85619837e880f6d5568c', {
    encrypted: true
  });

  var number = getPath();

  var channel = pusher.subscribe("player-channel-" + number);
  channel.bind('new-player', function(data) {
    // $('.turn').html(data.player_turn);
    showNewPlayer();
  });
}

function showNewPlayer(){
  var dataViewUrl = window.location.href + '/data_view/';
  $.get(dataViewUrl).success(function(data){
    newPlayer();
    if(data.black_player_id > 0){
      $('#blackPlayer').html(data.black_player_id);
    }else{
      $('#blackPlayer').html('waiting for black player to join');
    }
  });
}



$( document ).ready(function(){
  setBoard();
  showMove();
  showTurn();
  showNewPlayer();
  newPlayer();
});
