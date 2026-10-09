# English UI strings: the reference dictionary. `it` and `de` must have exactly
# the same keys and value types (checked by spec/i18n.spec.coffee).
define ->
  meta:
    siteName: 'USI — Università della Svizzera italiana'
    edition: 'Legacy Edition'
    description: 'The USI website, rebuilt on a retired 2012 front-end stack.'

  nav:
    main: 'Main'
    programmes: 'Programmes'
    explore: 'Explore'
    search: 'Search'
    searchShort: 'Search'
    menu: 'Menu'
    close: 'Close'
    skip: 'Skip to content'
    language: 'Language'
    home: 'USI Legacy Edition, home'
    lock: 'Lock'
    lockLabel: 'Lock this preview'

  theme:
    light: 'Light theme'
    dark: 'Dark theme'
    system: 'System theme'
    change: (current) -> "Change theme (currently #{current})"

  sections:
    education: { label: 'Study', blurb: 'Bachelor, Master, PhD and continuing education.' }
    research: { label: 'Research', blurb: 'Institutes, projects and research support.' }
    innovation: { label: 'Innovation', blurb: 'Start-ups, technology transfer and partnerships.' }
    university: { label: 'University', blurb: 'Who we are, campuses, services and practical info.' }
    other: { label: 'Other', blurb: '' }

  levels: { bachelor: 'Bachelor', master: 'Master', phd: 'PhD', executive: 'Executive' }

  faculties:
    architecture: { name: 'Academy of Architecture', short: 'Architecture' }
    'biomedical-sciences': { name: 'Faculty of Biomedical Sciences', short: 'Biomedical Sciences' }
    communication: { name: 'Faculty of Communication, Culture and Society', short: 'Communication, Culture & Society' }
    economics: { name: 'Faculty of Economics', short: 'Economics' }
    informatics: { name: 'Faculty of Informatics', short: 'Informatics' }
    theology: { name: 'Faculty of Theology of Lugano (affiliated)', short: 'Theology' }

  home:
    eyebrow: 'Università della Svizzera italiana · Lugano'
    mottoA: 'Create freely,'
    mottoB: 'act responsibly.'
    lede: 'One of Switzerland’s twelve certified public universities — six faculties, four campuses and a community from 115 countries, at the crossroads of Italian culture and global research.'
    intentStudy: 'I want to study'
    anyLevel: 'any level'
    levelOption: (level) -> "a #{level}"
    intentIn: 'in'
    anyField: 'any field'
    intentLevelLabel: 'Level'
    intentFieldLabel: 'Field'
    showProgrammes: 'Show programmes'
    searchHint: (n) -> "Or search #{n} pages — press / anywhere"
    factsLabel: 'USI in numbers'
    facts:
      students: 'students'
      staff: 'professors & researchers'
      countries: 'countries represented'
      founded: 'year founded'
    factsSource: 'Source: USI portrait'
    study:
      eyebrow: 'Study'
      title: 'Programmes taught by people who do the research.'
      lede: (n) -> "#{n} Bachelor and Master programmes, most of them taught in English."
      all: 'All programmes'
      scrollLeft: 'Scroll left'
      scrollRight: 'Scroll right'
      rail: 'Featured programmes'
    faculties:
      eyebrow: 'Faculties'
      title: 'Six faculties. One very connected campus.'
      lede: 'Small enough to know your professors, broad enough to cross disciplines.'
      count: (n) -> if n is 1 then '1 programme' else "#{n} programmes"
    events:
      eyebrow: 'Happening at USI'
      title: 'Lectures, seminars & events.'
      lede: 'From the USI events calendar.'
    areas:
      eyebrow: 'Find your way'
      title: 'Everything USI publishes, organised.'
      lede: (pages, kWords) -> "#{pages} real pages, #{kWords}k words — rebuilt into a structure you can actually navigate."
      allIn: (section) -> "All #{section.toLowerCase()} pages"
    cta:
      eyebrow: 'Your next step'
      title: 'Come and see Lugano for yourself.'
      find: 'Find a programme'
      search: 'Search open days'
    scene:
      label: 'USI’s West Campus in Lugano, with students in the courtyard and Monte San Salvatore behind'
      caption: 'West Campus, Lugano'
      credit: 'Photo: USI'
    legacy:
      eyebrow: 'Under the hood'
      title: 'Nine retired technologies, one modern site.'
      lede: 'No framework from this decade: CoffeeScript, Backbone, jQuery and friends — used the way senior developers wish they had been.'
      cta: 'Read the colophon'

  study:
    title: 'Find a programme'
    eyebrow: 'Programme finder'
    headingA: 'Find the programme'
    headingB: 'that fits you.'
    lede: 'Every Bachelor and Master currently published on usi.ch, in one place. Filter by level, faculty or teaching language — your selection lives in the URL, so you can share it.'
    filters: 'Filters'
    search: 'Search'
    searchPlaceholder: 'e.g. finance, AI'
    level: 'Level'
    all: 'All'
    faculty: 'Faculty'
    allFaculties: 'All faculties'
    taughtIn: 'Taught in'
    any: 'Any'
    english: 'English'
    italian: 'Italian'
    count: (n) -> if n is 1 then '1 programme' else "#{n} programmes"
    emptyTitle: 'Nothing matches those filters.'
    emptyHint: 'Try removing one, or search the whole site.'
    reset: 'Reset filters'

  programme:
    kind: (level) -> "#{level} programme"
    credits: 'ECTS'
    semesters: (n) -> if n is 1 then '1 semester' else "#{n} semesters"
    english: 'English'
    italian: 'Italian'
    and: '&'
    translated: 'Translated'
    englishOnly: 'English only'
    apply: 'Apply'

  explore:
    title: 'Explore'
    eyebrow: 'Explore'
    headingA: (n) -> "#{n} real pages,"
    headingB: 'one calm interface.'
    lede: (kWords) -> "Every public page mirrored from usi.ch, about #{kWords}k words, organised and searchable. Pick a topic or start typing."
    filter: 'Filter pages'
    placeholder: 'Filter pages — housing, scholarships, regulations…'
    everything: 'Everything'
    sections: 'Sections'
    count: (n) -> "#{n} pages"
    more: 'Show more'
    left: (n) -> "(#{n} left)"
    failed: 'The page index couldn’t be loaded. Please refresh.'
    empty: 'No pages match. Try a broader term.'

  page:
    loading: 'Loading page'
    breadcrumb: 'Breadcrumb'
    connection: 'Connection problem'
    errorTitle: 'We couldn’t load this page.'
    retry: 'Try again'
    notMirrored: 'Not mirrored yet'
    missingTitle: 'This page isn’t part of the redesign yet.'
    missingLede: 'It may still exist on the current USI website.'
    openOriginal: 'Open on usi.ch'
    searchInstead: 'Search instead'
    onThisPage: 'On this page'
    inSection: 'In this section'
    directory: 'This page is mostly a directory on the original site — see the links alongside.'
    quickLinks: 'Quick links'
    synced: (date) -> "Synced from usi.ch · #{date}"
    translatedNotice: ''
    translatedFrom: ''
    notTranslated: ''
    playVideo: 'Play video'
    media: 'Media'
    previous: 'Previous'
    next: 'Next'
    slideOf: (i, n) -> "#{i} of #{n}"

  search:
    dialog: 'Search USI'
    placeholder: 'Search programmes, pages, services…'
    results: 'Results'
    noResults: (q) -> "No results for “#{q}”."
    noResultsHint: 'Try a programme name, a service (“housing”, “scholarships”) or a campus.'
    groups: { goto: 'Go to', programmes: 'Programmes', pages: 'Pages' }
    navigate: 'navigate'
    open: 'open'
    close: 'close'
    loading: 'Loading the index…'
    indexed: (n) -> "#{n} pages indexed"
    shortcuts:
      study: { title: 'Find a programme', subtitle: 'Every Bachelor and Master at USI' }
      explore: { title: 'Explore all pages', subtitle: 'Browse the whole university by topic' }
      colophon: { title: 'Colophon', subtitle: 'How this edition was built' }

  notFound:
    title: 'Page not found'
    heading: 'This path leads into the lake.'
    lede: 'The page you’re looking for doesn’t exist here. Search for it, or head back to dry land.'
    search: 'Search'
    home: 'Back home'

  footer:
    label: 'Footer'
    address: 'Via Buffi 13, 6900 Lugano, Switzerland'
    exploreAll: (n) -> "Explore all #{n} pages"
    sourced: 'Content sourced from'
    concept: 'An independent redesign concept, built on a retired stack.'
    colophon: 'Colophon'
    motto: 'Create freely, act responsibly.'

  colophon:
    title: 'Colophon'
    eyebrow: 'Colophon'
    headingA: 'Built with the stack'
    headingB: 'we all moved on from.'
    lede: 'This edition of the USI website was written from scratch on nine technologies that senior front-end developers stopped reaching for years ago. Same real content, same design system — a different decade under the hood.'
    role: 'Role'
    better: 'What we did better'
    era: (year) -> "Released #{year}"
    principles: 'Principles'
    principleList: [
      'Progressive structure: every view is a Backbone.View with explicit render and teardown — no leaked listeners between routes.'
      'One bundle, one request: RequireJS modules compiled with r.js into a single minified file, then sealed with AES-256-GCM.'
      'Accessible by default: skip link, route announcements, focus management, keyboard search and WCAG AA colour contrast.'
      'Real content: thousands of usi.ch pages in English, Italian and Swiss German, loaded lazily per language.'
    ]
    stack:
      coffeescript:
        role: 'Every line of application code, the build tasks and the specs.'
        better: 'Small modules, no class hierarchies, and compiled output checked by our own spec runner.'
      backbone:
        role: 'Router, models, collections and views.'
        better: 'Views own their DOM and clean up on route change; finder filters live in a model that syncs to the URL.'
      jquery:
        role: 'DOM events, delegated handlers, Ajax and the number animations.'
        better: 'Version 3.7 with its security fixes, event delegation everywhere and no plugins.'
      underscore:
        role: 'Collection helpers, debouncing and grouping.'
        better: 'Pure functions only, so the search engine runs and is tested in Node too.'
      handlebars:
        role: 'Every template, precompiled at build time.'
        better: 'Only the small runtime ships, not the compiler; content is escaped by default and helpers handle i18n and links.'
      requirejs:
        role: 'AMD modules and the r.js optimiser.'
        better: 'Explicit dependencies per module, bundled into one file with the loader inlined.'
      less:
        role: 'The design system: tokens, mixins and the faculty palette.'
        better: 'Compiles to CSS custom properties, so light and dark themes switch at runtime.'
      grunt:
        role: 'The build: compile, precompile, bundle, test, serve and seal.'
        better: 'Custom tasks written for this project instead of a wall of plugins.'
      moment:
        role: 'Swiss-localised dates in English, Italian and German.'
        better: 'Only the two extra locales we need are bundled.'
