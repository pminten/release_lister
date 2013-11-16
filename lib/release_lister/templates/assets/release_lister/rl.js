$(document).ready(function(){
  $(".news-holder").click(function(){
    $(".news-more", this).slideToggle();
    $(".news-dots", this).toggle();
  });
});
