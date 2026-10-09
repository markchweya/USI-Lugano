# Facts that don't come from the crawl: faculties, key figures, the hero photo.
define ->
  faculties: ['architecture', 'biomedical-sciences', 'communication', 'economics', 'informatics', 'theology']

  # Published on usi.ch → University → Portrait. Update when USI publishes new numbers.
  facts: [
    { key: 'students', value: 4749 }
    { key: 'staff', value: 1591 }
    { key: 'countries', value: 115 }
    { key: 'founded', value: 1996, plain: true }
  ]

  portrait:
    en: '/en/university/who-we-are/at-a-glance'
    it: '/it/universita/chi-siamo/in-uno-sguardo'
    de: '/de/university/who-we-are/at-a-glance'

  openDays:
    en: 'open days'
    it: 'porte aperte'
    de: 'open days'

  hero: do ->
    base = 'https://www.usi.ch/sites/default/files/styles'
    file = 'public/storage/images/press-campus-lugano-web-03.jpg'
    src: "#{base}/usi_xlarge/#{file}?itok=bp1R-wRA"
    srcset: [
      "#{base}/usi_large/#{file}?itok=FeQPQAuJ 1200w"
      "#{base}/usi_xlarge/#{file}?itok=bp1R-wRA 1440w"
      "#{base}/usi_xxlarge/#{file}?itok=OdyWM1sE 2880w"
    ].join ', '
