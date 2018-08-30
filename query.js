const request = require('request-promise-native')

const projectsUrl = 'https://a806-housingconnect.nyc.gov/nyclottery/LttryProject/GetPublishedCurrentUpcomingProjects'
const neighborhoodLookupUrl = 'https://a806-housingconnect.nyc.gov/nyclottery/lottery/deferredjs/E7C31D21DC8111B2EE2A6A7B0D82B7D1/5.cache.js'

const mapResult = result => ({
  id: result.LttryProjSeqNo,
  name: result.ProjectName,
  startDate: result.AppStartDt,
  endDate: result.AppEndDt,
  published: result.Published,
  withdrawn: result.Withdrawn,
  mapLink: result.MapLink
})

const parseJson = jsonString =>
  new Promise((resolve, reject) => {
    try {
      const result = JSON.parse(jsonString)
      resolve(result)
    } catch (e) {
      reject(e)
    }
  })

request(projectsUrl)
  .then(parseJson)
  .then(({ Result: results }) => console.log(results.map(mapResult)))
