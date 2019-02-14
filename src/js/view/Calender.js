import { span, section, table, tr, th, td } from '@hyperapp/html'

const sundays = [...Array(365).keys()].map(d => new Date(2019, 0, d + 1)).filter(d => d.getDay() === 0)

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
    sundays.map(d => 
      th([
        span(d.getDate() <= 7 ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.getMonth()] : '')
      ])
    )
  ])

const TableBody = series => state =>
  tr([
    td(series.seriesName),
    sundays.map(d => ([
      check(d, series) ? td({ class: 'raceweek', 'data-tooltip': '24 Hours of Le Mans' }, span([d.getDate()])) : td([span(d.getDate())])
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