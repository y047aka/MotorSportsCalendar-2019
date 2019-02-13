// libraries
import axios from 'axios'

// Hyperapp
import { app } from 'hyperapp'
import { div, main } from '@hyperapp/html'

// views
import SiteHeader from './view/SiteHeader'
import SiteFooter from './view/SiteFooter';
import Profile from './view/Profile'
import Calender from './view/Calender'

const state = {
  calender: [
    { races: [] }
  ]
}

const actions = {
  setCalender: (newObj) => state => ({
    calender: newObj
  })
}

const view = (state, actions) => (
  div({
    oncreate: async () => {
      const calendars = await Promise.all([
        'F1_2019.json',
        'IndyCar_2019.json',
        'FormulaE_2018-19.json',
        'SuperFormula_2019.json',
        'WEC_2018-19.json',
        'WEC_2019-20.json',
        'IMSA_2019.json',
        'SuperGT_2019.json',
        'DTM_2019.json',
        'BlancpainGT_2019.json',
        'WTCR_2019.json',
        'NASCAR_2019.json',
        'WRC_2019.json',
        'MotoGP_2019.json',
        'AirRace_2019.json'
      ].map(d => 
        axios.get(`https://y047aka.github.io/MotorSportsSchedules/${ d }`).catch(e => { console.log(e) })
      ))

      actions.setCalender(calendars.map(d => d.data))
    }
  }, [
    SiteHeader(),
    main([
      Calender(),
      Profile()
    ]),
    SiteFooter()
  ])
)

app(state, actions, view, document.body)