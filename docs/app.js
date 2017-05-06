$(function() {
    //----- OPEN
    $('[data-popup-open]').on('click', function(e)  {
        var targeted_popup_class = jQuery(this).attr('data-popup-open');
        $('[data-popup="' + targeted_popup_class + '"]').fadeIn(350);
 
        e.preventDefault();
    });
 
    //----- CLOSE
    $('[data-popup-close]').on('click', function(e)  {
        var targeted_popup_class = jQuery(this).attr('data-popup-close');
        $('[data-popup="' + targeted_popup_class + '"]').fadeOut(350);
        e.preventDefault();
    });
});

function readFile() {
  
  if (this.files && this.files[0]) {
    
    var FR= new FileReader();
    
    FR.addEventListener("load", function(e) {
      document.getElementById("img").src       = e.target.result;
      document.getElementById("b64").innerHTML = e.target.result;
    }); 
    
    FR.readAsDataURL( this.files[0] );
  }
  
}



document.getElementById("inp").addEventListener("change", readFile); // listens for when the files gest aj

//Init Firebase
  var config = {
    apiKey: "AIzaSyDiWoWULQCn9qoe4pDxeISiG-OQq1Cm2m4",
    authDomain: "uvdetection.firebaseapp.com",
      databaseURL: "https://uvdetection.firebaseio.com",
      storageBucket: "uvdetection.appspot.com",
      messagingSenderId: "395578570263"
  };
  firebase.initializeApp(config);

