import { section, h1, h2, a, ul, li } from '@hyperapp/html'

export default () => state =>
  section([
    h1('Links'),
    h2('FIA'),
    ul(
      [
        { title: 'The complete 2019 F1 Championship calendar| Formula 1®', url: 'https://www.formula1.com/en/racing/2019.html' },
        { title: 'Calendar - FIA World Endurance Championship', url: 'https://www.fiawec.com/en/calendar/80' },
        { title: 'Race Calendar | FIA Formula E', url: 'https://www.fiaformulae.com/en/championship/race-calendar' },
        { title: 'Rally Calendar Overview | WRC Start Dates | WRC Info - wrc.com', url: 'https://www.wrc.com/en/wrc/calendar/calendar/page/671-29772-16--.html' }
      ].map(d =>
        li([
          a({ href: d.url, target: '_blank' }, d.title)
        ])
      )
    ),

    h2('FIM'),
    ul([
      li([
        a({ href: 'http://www.motogp.com/en/calendar', target: '_blank' }, 'MotoGP 2019 calendar - Circuits, the schedule and information about every Grand Prix | MotoGP™')
      ])
    ]),

    h2('America'),
    ul(
      [
        { title: 'Schedule - Verizon IndyCar Series, Indy Lights, Pro Mazda & Cooper Tires USF2000', url: 'https://www.indycar.com/Schedule' },
        { title: 'Schedule | WeatherTech SportsCar Championship', url: 'https://sportscarchampionship.imsa.com/schedule-results/race-schedule' },
        { title: '2019 Monster Energy NASCAR Cup Series Schedule | NASCAR.com', url: 'https://www.nascar.com/monster-energy-nascar-cup-series/2019/schedule/' }
      ].map(d =>
        li([
          a({ href: d.url, target: '_blank' }, d.title)
        ])
      )
    ),

    h2('Japan'),
    ul(
      [
        { title: 'Races | SUPER GT OFFICIAL WEBSITE', url: 'https://supergt.net/races' },
        { title: 'Race Calendar 2019 | SUPER FORMULA Official Website', url: 'https://superformula.net/sf2/en/race2019/' }
      ].map(d =>
        li([
          a({ href: d.url, target: '_blank' }, d.title)
        ])
      )
    )
  ])