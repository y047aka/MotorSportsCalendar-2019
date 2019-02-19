import { section, h1, h2, a } from '@hyperapp/html'

export default () => state =>
  section([
    h1('Repositories'),
    h2('Program:'),
    a({ href: 'https://github.com/y047aka/MotorSportsCalendar', target: '_blank' }, 'https://github.com/y047aka/MotorSportsCalendar'),
    h2('Data:'),
    a({ href: 'https://github.com/y047aka/MotorSportsData/tree/master/schedules', target: '_blank' }, 'https://github.com/y047aka/MotorSportsData/schedules')        
  ])