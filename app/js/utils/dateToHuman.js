export default (date) => {
  let hours = date.getHours()
  let minutes = date.getMinutes()
  const period = hours >= 12 ? 'PM' : 'AM'
  hours = hours % 12
  hours = hours === 0 ? 12 : hours
  minutes = minutes < 10 ? `0${minutes}` : minutes
  return `${hours}:${minutes}${period}`
}
