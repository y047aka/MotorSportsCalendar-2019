import { header, h1 } from '@hyperapp/html'

export default () => state =>
  header({ class: 'site-header' }, [
    h1('Motor Sports Calendar 2019')
  ])
