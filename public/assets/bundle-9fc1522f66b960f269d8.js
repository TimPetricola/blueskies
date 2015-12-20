!function(n){function e(r){if(t[r])return t[r].exports;var s=t[r]={exports:{},id:r,loaded:!1};return n[r].call(s.exports,s,s.exports,e),s.loaded=!0,s.exports}var t={};return e.m=n,e.c=t,e.p="",e(0)}([function(module,exports,__webpack_require__){eval("__webpack_require__(1);\nmodule.exports = __webpack_require__(2);\n\n\n/*****************\n ** WEBPACK FOOTER\n ** multi bundle\n ** module id = 0\n ** module chunks = 0\n **/\n//# sourceURL=webpack:///multi_bundle?")},function(module,exports){eval("'use strict';\n\nfunction _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }\n\nvar dateToHuman = function dateToHuman(date) {\n  var hours = date.getHours();\n  var minutes = date.getMinutes();\n  var period = hours >= 12 ? 'PM' : 'AM';\n  hours = hours % 12;\n  hours = hours === 0 ? 12 : hours;\n  minutes = minutes < 10 ? '0' + minutes : minutes;\n  return hours + ':' + minutes + period;\n};\n\n// Form\nvar tzInputs = document.querySelectorAll('.js-input-timezone');\nvar localTimeLabel = document.querySelectorAll('.js-local-time-human');\nvar interestsInputs = document.querySelectorAll('.js-interest-input');\nvar sampleLink = document.querySelector('.js-sample-link');\nvar samplePath = sampleLink.href;\n\nvar selectedInterests = function selectedInterests() {\n  var selected = document.querySelectorAll('.js-interest-input:checked');\n  return [].concat(_toConsumableArray(selected)).map(function (s) {\n    return s.value;\n  });\n};\n\nvar updateSampleLink = function updateSampleLink() {\n  var href = samplePath;\n  var selected = selectedInterests();\n\n  if (selected.length) {\n    href += '?' + selected.map(function (id) {\n      return 'interests[]=' + id;\n    }).join('&');\n  }\n\n  sampleLink.href = href;\n};[].concat(_toConsumableArray(tzInputs)).forEach(function (input) {\n  input.value = new Date().getTimezoneOffset() / 60;\n});[].concat(_toConsumableArray(localTimeLabel)).forEach(function (node) {\n  node.innerText = dateToHuman(new Date());\n});[].concat(_toConsumableArray(interestsInputs)).forEach(function (input) {\n  input.addEventListener('change', updateSampleLink);\n});\n\nupdateSampleLink();\n\n// Interests spinner\nvar spinner = document.querySelector('.js-interest-spinner');\n\nvar current = document.querySelector('.js-interest-spinner-current');\nvar next = document.querySelector('.js-interest-spinner-next');\nvar words = spinner.getAttribute('data-words').split(',');\n\nvar index = 0;\nvar nextIndex = 1;\n\nnext.textContent = words[nextIndex];\nspinner.style.width = current.offsetWidth + 'px';\n\nvar spin = function spin(first) {\n  index = nextIndex;\n  nextIndex++;\n\n  if (nextIndex >= words.length) {\n    nextIndex = 0;\n  }\n\n  spinner.style.width = next.offsetWidth + 'px';\n\n  current.textContent = words[index];\n  next.textContent = words[nextIndex];\n};\n\nsetInterval(spin, 3000);\n\n/*****************\n ** WEBPACK FOOTER\n ** ./app/js/app.js\n ** module id = 1\n ** module chunks = 0\n **/\n//# sourceURL=webpack:///./app/js/app.js?")},function(module,exports){eval("// removed by extract-text-webpack-plugin\n\n/*****************\n ** WEBPACK FOOTER\n ** ./app/css/app.css\n ** module id = 2\n ** module chunks = 0\n **/\n//# sourceURL=webpack:///./app/css/app.css?")}]);