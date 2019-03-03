import { div, span, section, table, tr, th, td, input, label } from '@hyperapp/html'

const sundays = [...Array(365).keys()].map(d => new Date(2019, 0, d + 1)).filter(d => d.getDay() === 0)

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
    sundays.map(sunday => {
      const event = series.races.reverse().find(s => {
        const difference = sunday - new Date(s.date.replace(/-/g, '/'))
        return (difference >= 0 && difference < 7 * (1000 * 60 * 60 * 24))
      })

      const today = new Date()

      if (event) {
        return td({ class: 'raceweek' }, [
          label([
            span([sunday.getDate()]),
            input({ type: 'checkbox', name: `checkbox${ series.seriesName }` }),
            div({ innerHTML: `${ event.date }<br>${ event.name }` })
          ])
        ])
      } else if (sunday < today.setDate(today.getDate() - 1)) {
        return td({ class: 'past' }, '')
      } else {
        return td('')
      }
    })
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