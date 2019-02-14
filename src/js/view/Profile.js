import { section, h1, h2, p, a, ul, li } from '@hyperapp/html'

export default () => state =>
  section([
    h1('Links'),
    h2('FIA'),
    ul(
      [
        { title: 'The complete 2019 F1 Championship calendar| Formula 1®', url: 'https://www.formula1.com/en/racing/2019.html' },
        { title: 'Calendar - FIA World Endurance Championship', url: 'https://www.fiawec.com/en/calendar/80' }
      ].map(d =>
        li([
          a({ href: d.url, target: '_blank' }, d.title)
        ])
      )
    ),

    h1('Repositories'),
    h2('Program:'),
    a({ href: 'https://github.com/y047aka/MotorSportsCalendar', target: '_blank' }, 'https://github.com/y047aka/MotorSportsCalendar'),
    h2('Data:'),
    a({ href: 'https://github.com/y047aka/MotorSportsSchedules', target: '_blank' }, 'https://github.com/y047aka/MotorSportsSchedules')
  ])