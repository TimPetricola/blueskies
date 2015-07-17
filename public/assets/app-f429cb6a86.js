'use strict';

var util = (function () {
  var nodeArray = function nodeArray(nodeList) {
    return [].slice.call(nodeList);
  };

  return { nodeArray: nodeArray };
})();

var Form = (function (util) {
  var tzInputs = document.querySelectorAll('.js-input-timezone');
  var localTimeLabel = document.querySelectorAll('.js-local-time-human');
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

  var dateToHumanTime = function dateToHumanTime(date) {
    var hours = date.getHours();
    var minutes = date.getMinutes();
    var period = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours ? hours : 12;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    return hours + ':' + minutes + period;
  };

  util.nodeArray(tzInputs).forEach(function (input) {
    input.value = new Date().getTimezoneOffset() / 60;
  });

  util.nodeArray(localTimeLabel).forEach(function (node) {
    node.innerText = dateToHumanTime(new Date());
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