particlesJS('particles');

const util = (() => {
  const nodeArray = (nodeList) => [].slice.call(nodeList);

  return { nodeArray };
})();

const Form = ((util) => {
  const tzInputs = document.querySelectorAll('.js-input-timezone');
  const interestsInputs = document.querySelectorAll('.js-interest-input');
  const sampleLink = document.querySelector('.js-sample-link');
  const samplePath = sampleLink.href;

  const selectedInterests = function() {
    const selected = document.querySelectorAll('.js-interest-input:checked');
    return util.nodeArray(selected).map((s) => s.value)
  };

  const updateSampleLink = function() {
    let href = samplePath;
    const selected = selectedInterests();

    if(selected.length) {
      href += '?' + selected.map((id) => 'interests[]=' + id).join('&');
    }

    sampleLink.href = href;
  };

  util.nodeArray(tzInputs).forEach((input) => {
    input.value = new Date().getTimezoneOffset() / 60;
  });

  util.nodeArray(interestsInputs).forEach((input) => {
    input.addEventListener('change', updateSampleLink);
  });

  updateSampleLink();
})(util);
