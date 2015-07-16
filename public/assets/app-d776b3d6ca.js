'use strict';

var util = (function () {
  var nodeArray = function nodeArray(nodeList) {
    return [].slice.call(nodeList);
  };

  return { nodeArray: nodeArray };
})();

var Form = (function (util) {
  var tzInputs = document.querySelectorAll('.js-input-timezone');
  var interestsInputs = document.querySelectorAll('.js-interest-input');
  var sampleLink = document.querySelector('.js-sample-link');
  var samplePath = sampleLink.href;

  var selectedInterests = function selectedInterests() {
    var selected = document.querySelectorAll('.js-interest-input:checked');
    return util.nodeArray(selected).map(function (s) {
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
  };

  util.nodeArray(tzInputs).forEach(function (input) {
    input.value = new Date().getTimezoneOffset() / 60;
  });

  util.nodeArray(interestsInputs).forEach(function (input) {
    input.addEventListener('change', updateSampleLink);
  });

  updateSampleLink();
})(util);

var InterestsSpinner = (function () {
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
})();