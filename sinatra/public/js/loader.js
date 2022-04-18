function showLoader(){
  const loaderDiv = document.getElementById('loader');
  $('.content').hide();
  $(loaderDiv).show();
}

function hideLoader(){
  const loaderDiv = document.getElementById('loader');
  $(loaderDiv).hide();
  $('.content').show();
}

$('a').on('click', function(){
  showLoader();
});
$('button').on('click', function(){
  showLoader();
});

window.addEventListener("beforeunload", function(event) {
  console.log("The page is redirecting")
  showLoader();
});
window.addEventListener('load', hideLoader);
