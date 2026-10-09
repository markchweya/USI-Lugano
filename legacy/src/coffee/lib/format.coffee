# Swiss number formatting (4’749) and localised dates through Moment.js.
define ['moment', 'moment-locale/it', 'moment-locale/de'], (moment) ->
  format =
    number: (n) ->
      String(Math.round n).replace /\B(?=(\d{3})+(?!\d))/g, '’'

    thousands: (n) -> format.number Math.round(n / 1000)

    date: (value, lang) ->
      m = moment value, moment.ISO_8601, true
      if m.isValid() then m.locale(lang).format('LL') else ''

    # "6 semesters" → years when it reads better is the template's job; this is just arithmetic.
    years: (semesters) -> semesters / 2
