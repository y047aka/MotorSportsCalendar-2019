import { span, section, table, tr, th, td } from '@hyperapp/html'

const array = (() => {
  const array = []
  for (var i = 0; i < 365; i++) {
    array.push(new Date(2019, 0, i + 1))
  }
  return array.filter(d => d.getDay() === 0)
})()

const check = (sunday, series) => {
  const a = series.races.filter(d => {
    const difference = sunday - new Date(d.date.replace(/-/g, '/'))
    return (difference >= 0 && difference < 7 * (1000 * 60 * 60 * 24))
  }).length
  return a
}

const TableHead = () => state =>
  tr([
    th(''),
    array.map(d => 
      th([
        span(d.getDate() <= 7 ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.getMonth()] : '')
      ])
    )
  ])

const TableBody = series => state =>
  tr([
    td(series.seriesName),
    array.map(d => ([
      check(d, series) ? td({ class: 'raceweek', 'data-tooltip': '24 Hours of Le Mans' }, '') : td('')
    ]))
  ])

export default () => state =>
  section([
    table({ class: 'heatmap' }, [
      state.calender.map(series => [
        TableHead(series),
        TableBody(series)
      ])
    ])
  ])