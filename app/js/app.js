import Vue from 'vue'
import dateToHuman from './utils/dateToHuman'

// Form
const tzInputs = document.querySelectorAll('.js-input-timezone')
const interestsInputs = document.querySelectorAll('.js-interest-input')
const sampleLink = document.querySelector('.js-sample-link')
const linksList = document.querySelector('.js-links-list')
const samplePath = linksList.getAttribute('data-sample-path')

const selectedInterests = () => {
  const selected = document.querySelectorAll('.js-interest-input:checked')
  return [...selected].map((s) => s.value)
}

// List
const linksListView = new Vue({
  el: '#links-list',
  data: { links: [], samplePath }
})

const refreshLinksList = () => {
  const selected = selectedInterests()
  let queryParams = ''

  if (selected.length) {
    queryParams += '?' + selected.map(id => 'interests[]=' + id).join('&')
  }

  linksListView.samplePath = samplePath + queryParams

  fetch(linksList.getAttribute('data-path') + queryParams)
    .then(response => response.json())
    .then(json => { linksListView.links = json })
}

;[...tzInputs].forEach((input) => {
  input.value = new Date().getTimezoneOffset() / 60
})

;[...interestsInputs].forEach((input) => {
  input.addEventListener('change', refreshLinksList)
})

refreshLinksList()


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
