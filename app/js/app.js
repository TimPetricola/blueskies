const dateToHuman = (date) => {
  let hours = date.getHours()
  let minutes = date.getMinutes()
  const period = hours >= 12 ? 'PM' : 'AM'
  hours = hours % 12
  hours = hours === 0 ? 12 : hours
  minutes = minutes < 10 ? `0${minutes}` : minutes
  return `${hours}:${minutes}${period}`
}

// Form
const tzInputs = document.querySelectorAll('.js-input-timezone')
const localTimeLabel = document.querySelectorAll('.js-local-time-human')
const interestsInputs = document.querySelectorAll('.js-interest-input')
const sampleLink = document.querySelector('.js-sample-link')
const samplePath = sampleLink.href

const selectedInterests = () => {
  const selected = document.querySelectorAll('.js-interest-input:checked')
  return [...selected].map((s) => s.value)
}

const updateSampleLink = () => {
  let href = samplePath
  const selected = selectedInterests()

  if (selected.length) {
    href += '?' + selected.map((id) => 'interests[]=' + id).join('&')
  }

  sampleLink.href = href
}

;[...tzInputs].forEach((input) => {
  input.value = new Date().getTimezoneOffset() / 60
})

;[...localTimeLabel].forEach((node) => {
  node.innerText = dateToHuman(new Date())
})

;[...interestsInputs].forEach((input) => {
  input.addEventListener('change', updateSampleLink)
})

updateSampleLink()

// Interests spinner
const spinner = document.querySelector('.js-interest-spinner')

const current = document.querySelector('.js-interest-spinner-current')
const next = document.querySelector('.js-interest-spinner-next')
const words = spinner.getAttribute('data-words').split(',')

let index = 0
let nextIndex = 1

next.textContent = words[nextIndex]
spinner.style.width = `${current.offsetWidth}px`

const spin = (first) => {
  index = nextIndex
  nextIndex++

  if (nextIndex >= words.length) {
    nextIndex = 0
  }

  spinner.style.width = `${next.offsetWidth}px`

  current.textContent = words[index]
  next.textContent = words[nextIndex]
}

setInterval(spin, 3000)
