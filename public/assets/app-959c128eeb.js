'use strict';

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

var dateToHuman = function dateToHuman(date) {
  var hours = date.getHours();
  var minutes = date.getMinutes();
  var period = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours === 0 ? 12 : hours;
  minutes = minutes < 10 ? '0' + minutes : minutes;
  return hours + ':' + minutes + period;
};

// Form
var tzInputs = document.querySelectorAll('.js-input-timezone');
var localTimeLabel = document.querySelectorAll('.js-local-time-human');
var interestsInputs = document.querySelectorAll('.js-interest-input');
var sampleLink = document.querySelector('.js-sample-link');
var samplePath = sampleLink.href;

var selectedInterests = function selectedInterests() {
  var selected = document.querySelectorAll('.js-interest-input:checked');
  return [].concat(_toConsumableArray(selected)).map(function (s) {
    return s.value;
  });
};

var updateSampleLink = function updateSampleLink() {
  var href = samplePath;
  var selected = selectedInterests();

  if (selected.length) {
    href += '?' + selected.map(function (id) {
      return 'interests[]=' + id;
    }).join('&');
  }

  sampleLink.href = href;
};[].concat(_toConsumableArray(tzInputs)).forEach(function (input) {
  input.value = new Date().getTimezoneOffset() / 60;
});[].concat(_toConsumableArray(localTimeLabel)).forEach(function (node) {
  node.innerText = dateToHuman(new Date());
});[].concat(_toConsumableArray(interestsInputs)).forEach(function (input) {
  input.addEventListener('change', updateSampleLink);
});

updateSampleLink();

// Interests spinner
var spinner = document.querySelector('.js-interest-spinner');

var current = document.querySelector('.js-interest-spinner-current');
var next = document.querySelector('.js-interest-spinner-next');
var words = spinner.getAttribute('data-words').split(',');

var index = 0;
var nextIndex = 1;

next.textContent = words[nextIndex];
spinner.style.width = current.offsetWidth + 'px';

var spin = function spin(first) {
  index = nextIndex;
  nextIndex++;

  if (nextIndex >= words.length) {
    nextIndex = 0;
  }

  spinner.style.width = next.offsetWidth + 'px';

  current.textContent = words[index];
  next.textContent = words[nextIndex];
};

setInterval(spin, 3000);