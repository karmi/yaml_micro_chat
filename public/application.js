var Application = {
  
  // Initialize the application: Start the updater, focus input, etc
  initialize : function() {
    this.start();
    Form.focusFirstElement('speaker');
    $('speaker').observe( 'submit', function(e) { Application.speak(); e.stop(); } );
  },
  
  // Run the updater
  run : function() {
    // Get the last ID = last retrieved message from the server
    from = $$('#chat p').last().identify();
    this.updater = new Ajax.Updater('chat', '/listen', 
    { asynchronous:true, 
      method: 'get',
      parameters: { from: from }, // Pull only new messages
      insertion: Insertion.Bottom,
      onCreate:  function() { },
      onSuccess: function() { $('info').scrollTo() }
    }
    );
  },
  
  // Start the updater
  // NOTE : Why this? Why not http://www.prototypejs.org/api/ajax/periodicalUpdater
  //        Well... Let's say, it gives weird random pains in Firefox :)
  start: function() {
    this.interval = setInterval('Application.run()', 2000);
  },
  
  // Stop the updater
  stop : function() {
    clearInterval(this.interval);
    this.updater = null;
  },
  
  // Send message
  speak: function() {
    // Get text from inputs...
    var author  = $('author').getValue();
    var message = $('message').getValue();
    if ( author=='' || message=='' ) { alert('You wanna say, uhm... nothing?'); return; }
    // ...and post it to server...
    new Ajax.Request( '/speak', {parameters: { author: author, message: message } } );
    $('message').clear().focus();
    $('speaker').scrollTo();
  }
  
}