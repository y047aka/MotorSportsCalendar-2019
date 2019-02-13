import { section, h1, h2, p, a, ul, li } from '@hyperapp/html'

export default () => state =>
  section([
    h1('Repositories'), 
    h2('Program:'),
    a({ href: 'https://github.com/y047aka/MotorSportsCalandar', target: '_blank' }, 'https://github.com/y047aka/MotorSportsCalandar'),
    h2('Data:'),
    a({ href: 'https://github.com/y047aka/MotorSportsSchedules', target: '_blank' }, 'https://github.com/y047aka/MotorSportsSchedules'),
    h1('Links'),
    h2('FIA'),
    ul([
      li([
        a({ href: 'https://www.formula1.com/en/racing/2019.html', target: '_blank' }, 'The complete 2019 F1 Championship calendar| Formula 1®')
      ]),
      li([
        a({ href: 'https://www.fiawec.com/en/calendar/80', target: '_blank' }, 'Calendar - FIA World Endurance Championship')
      ])
    ])
  ])