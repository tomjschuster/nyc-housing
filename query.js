const request = require('request-promise-native')

const projectsUrl = 'https://a806-housingconnect.nyc.gov/nyclottery/LttryProject/GetPublishedCurrentUpcomingProjects'
const neighborhoodLookupUrl = 'https://a806-housingconnect.nyc.gov/nyclottery/LttryLookup/LookupValues?name=Neighborhood-'

const mapLookupValue = result => ({
  id: result.LttryLookupSeqNo,
  shortName: result.ShortName,
  longName: result.LongName,
  sortOrder: result.SortOrder,
  valueType: result.lookupName
})

const lookupValueListToHash = ([list]) => {
  const hash = {}
  for (let value of list) {
    const mappedValue = mapLookupValue(value)
    hash[mappedValue.id] = mappedValue
  }
  return hash
}

const padLeft = (padder, length, v) => padder.repeat(length - v.length) + v
const padMonthDay = padLeft.bind(null, '0', 2)

const parseStartEndDate = dateString => {
  const [m, d, y] = dateString.split('/')
  return new Date(`${y}-${padMonthDay(m)}-${padMonthDay(d)}T00:00:00`)
}

const parsePublishedDate = dateString => {
  const unixTimestamp = parseInt(dateString.replace(/(Date|\/)/g, ''), 10)
  return new Date(unixTimestamp)
}

const toTitleCase = string =>
  string
    .split('')
    .map((l, i) => i ? l.toLowerCase() : l.toUpperCase())
    .join('')

const parseAddresses = url =>
  url
    .split('s=')[1]
    .replace(/a:/g, '')
    .split(';')
    .map(x => {
      const [number, street, borough] =
        x.split(',').map(x => x.split('+').map(toTitleCase).join(' '))

      return `${number} ${street}, ${borough}, NY`
    })

const mapProjectResult = (neighborhoodLookup, result) => ({
  id: result.LttryProjeqNo,
  name: result.ProjectName,
  neighborhood: neighborhoodLookup[result.NeighborhoodLkp],
  startDate: result.AppStartDt && parseStartEndDate(result.AppStartDt),
  endDate: result.AppEndDt && parseStartEndDate(result.AppEndDt),
  publishedDate: result.PublishedDate && parsePublishedDate(result.PublishedDate),
  published: result.Published,
  withdrawn: result.Withdrawn,
  addresses: parseAddresses(result.MapLink)
})

const mapProjectResults = (neighborhoodLookup, results) =>
  results.map(mapProjectResult.bind(null, neighborhoodLookup))

const parseJson = jsonString =>
  new Promise((resolve, reject) => {
    try {
      const result = JSON.parse(jsonString)
      resolve(result)
    } catch (e) {
      reject(e)
    }
  })

const parseResult = result => parseJson(result).then(({ Result }) => Result)

const getNeighborhoodLookup = () =>
  request(neighborhoodLookupUrl)
    .then(parseResult)
    .then(lookupValueListToHash)

const getProjects = (neighborhoodLookup) =>
  request(projectsUrl)
    .then(parseResult)
    .then(mapProjectResults.bind(null, neighborhoodLookup))

async function query () {
  const neighborhoodLookup = await getNeighborhoodLookup()
  const projects = await getProjects(neighborhoodLookup)
  console.log(projects)
}

query()
