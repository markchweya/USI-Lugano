# Deutsch: Schweizer Hochdeutsch (ss statt ß, Sie-Form). Die USI publiziert
# keine deutschen Seiten; übersetzte Inhalte sind als solche gekennzeichnet.
define ->
  meta:
    siteName: 'USI — Università della Svizzera italiana'
    edition: 'Legacy Edition'
    description: 'Die Website der USI, neu gebaut mit einem Frontend-Stack von 2012.'

  nav:
    main: 'Hauptnavigation'
    programmes: 'Studiengänge'
    explore: 'Entdecken'
    search: 'Suche'
    searchShort: 'Suchen'
    menu: 'Menü'
    close: 'Schliessen'
    skip: 'Zum Inhalt springen'
    language: 'Sprache'
    home: 'USI Legacy Edition, Startseite'
    lock: 'Sperren'
    lockLabel: 'Diese Vorschau sperren'

  theme:
    light: 'Helles Design'
    dark: 'Dunkles Design'
    system: 'Systemeinstellung'
    change: (current) -> "Design wechseln (aktuell: #{current})"

  sections:
    education: { label: 'Studium', blurb: 'Bachelor, Master, Doktorat und Weiterbildung.' }
    research: { label: 'Forschung', blurb: 'Institute, Projekte und Forschungsförderung.' }
    innovation: { label: 'Innovation', blurb: 'Start-ups, Technologietransfer und Partnerschaften.' }
    university: { label: 'Universität', blurb: 'Über uns, Campus, Dienstleistungen und praktische Infos.' }
    other: { label: 'Weiteres', blurb: '' }

  levels: { bachelor: 'Bachelor', master: 'Master', phd: 'Doktorat', executive: 'Executive' }

  faculties:
    architecture: { name: 'Architekturakademie (Accademia di architettura)', short: 'Architektur' }
    'biomedical-sciences': { name: 'Fakultät für Biomedizinische Wissenschaften', short: 'Biomedizin' }
    communication: { name: 'Fakultät für Kommunikation, Kultur und Gesellschaft', short: 'Kommunikation, Kultur & Gesellschaft' }
    economics: { name: 'Fakultät für Wirtschaftswissenschaften', short: 'Wirtschaftswissenschaften' }
    informatics: { name: 'Fakultät für Informatik', short: 'Informatik' }
    theology: { name: 'Theologische Fakultät Lugano (assoziiert)', short: 'Theologie' }

  home:
    eyebrow: 'Università della Svizzera italiana · Lugano'
    mottoA: 'Frei gestalten,'
    mottoB: 'verantwortungsvoll handeln.'
    lede: 'Eine der zwölf akkreditierten öffentlichen Universitäten der Schweiz – sechs Fakultäten, vier Campus und eine Gemeinschaft aus 115 Ländern, wo italienische Kultur auf internationale Forschung trifft.'
    intentStudy: 'Ich suche'
    anyLevel: 'einen Studiengang'
    levelOption: (level) -> if level is 'Doktorat' then "ein #{level}" else "einen #{level}"
    intentIn: 'in'
    anyField: 'einem beliebigen Fach'
    intentLevelLabel: 'Stufe'
    intentFieldLabel: 'Fach'
    showProgrammes: 'Studiengänge anzeigen'
    searchHint: (n) -> "Oder #{n} Seiten durchsuchen – drücken Sie / auf jeder Seite"
    factsLabel: 'Die USI in Zahlen'
    facts:
      students: 'Studierende'
      staff: 'Professorinnen, Professoren & Forschende'
      countries: 'Herkunftsländer'
      founded: 'Gründungsjahr'
    factsSource: 'Quelle: Porträt der USI'
    study:
      eyebrow: 'Studium'
      title: 'Lehre von Menschen, die selbst forschen.'
      lede: (n) -> "#{n} Bachelor- und Masterstudiengänge, die meisten davon auf Englisch."
      all: 'Alle Studiengänge'
      scrollLeft: 'Nach links scrollen'
      scrollRight: 'Nach rechts scrollen'
      rail: 'Ausgewählte Studiengänge'
    faculties:
      eyebrow: 'Fakultäten'
      title: 'Sechs Fakultäten. Ein eng vernetzter Campus.'
      lede: 'Klein genug, um die Professorinnen und Professoren persönlich zu kennen – breit genug für interdisziplinäres Arbeiten.'
      count: (n) -> if n is 1 then '1 Studiengang' else "#{n} Studiengänge"
    events:
      eyebrow: 'An der USI'
      title: 'Vorträge, Seminare & Veranstaltungen.'
      lede: 'Aus dem Veranstaltungskalender der USI (Titel in Originalsprache).'
    areas:
      eyebrow: 'Orientierung'
      title: 'Alles, was die USI veröffentlicht – geordnet.'
      lede: (pages, kWords) -> "#{pages} echte Seiten, #{kWords}k Wörter – neu aufgebaut zu einer Struktur, in der man sich zurechtfindet."
      allIn: (section) -> "Alle Seiten zu #{section}"
    cta:
      eyebrow: 'Ihr nächster Schritt'
      title: 'Lernen Sie Lugano persönlich kennen.'
      find: 'Studiengang finden'
      search: 'Infotage suchen'
    scene:
      label: 'Der Campus West der USI in Lugano mit Studierenden im Innenhof und dem Monte San Salvatore im Hintergrund'
      caption: 'Campus West, Lugano'
      credit: 'Foto: USI'
    legacy:
      eyebrow: 'Unter der Haube'
      title: 'Neun ausgemusterte Technologien, eine moderne Website.'
      lede: 'Kein Framework aus diesem Jahrzehnt: CoffeeScript, Backbone, jQuery und Co. – so eingesetzt, wie es sich erfahrene Entwicklerinnen und Entwickler immer gewünscht hätten.'
      cta: 'Zum Kolophon'

  study:
    title: 'Studiengang finden'
    eyebrow: 'Studiengangsfinder'
    headingA: 'Finden Sie den Studiengang,'
    headingB: 'der zu Ihnen passt.'
    lede: 'Alle Bachelor- und Masterstudiengänge, die derzeit auf usi.ch veröffentlicht sind, an einem Ort. Filtern Sie nach Stufe, Fakultät oder Unterrichtssprache – Ihre Auswahl steht in der URL und lässt sich teilen.'
    filters: 'Filter'
    search: 'Suche'
    searchPlaceholder: 'z. B. Finanzen, KI'
    level: 'Stufe'
    all: 'Alle'
    faculty: 'Fakultät'
    allFaculties: 'Alle Fakultäten'
    taughtIn: 'Unterrichtssprache'
    any: 'Alle'
    english: 'Englisch'
    italian: 'Italienisch'
    count: (n) -> if n is 1 then '1 Studiengang' else "#{n} Studiengänge"
    emptyTitle: 'Kein Studiengang entspricht diesen Filtern.'
    emptyHint: 'Entfernen Sie einen Filter oder durchsuchen Sie die ganze Website.'
    reset: 'Filter zurücksetzen'

  programme:
    kind: (level) -> "#{level}studiengang"
    credits: 'ECTS'
    semesters: (n) -> if n is 1 then '1 Semester' else "#{n} Semester"
    english: 'Englisch'
    italian: 'Italienisch'
    and: '&'
    translated: 'Übersetzt'
    englishOnly: 'Nur auf Englisch'
    apply: 'Bewerben'

  explore:
    title: 'Entdecken'
    eyebrow: 'Entdecken'
    headingA: (n) -> "#{n} echte Seiten,"
    headingB: 'eine ruhige Oberfläche.'
    lede: (kWords) -> "Alle öffentlichen Seiten von usi.ch, rund #{kWords}k Wörter, geordnet und durchsuchbar. Wählen Sie ein Thema oder tippen Sie einfach los."
    filter: 'Seiten filtern'
    placeholder: 'Seiten filtern – Wohnen, Stipendien, Reglemente…'
    everything: 'Alles'
    sections: 'Bereiche'
    count: (n) -> "#{n} Seiten"
    more: 'Mehr anzeigen'
    left: (n) -> "(noch #{n})"
    failed: 'Der Seitenindex konnte nicht geladen werden. Bitte laden Sie die Seite neu.'
    empty: 'Keine passenden Seiten. Versuchen Sie einen allgemeineren Begriff.'

  page:
    loading: 'Seite wird geladen'
    breadcrumb: 'Brotkrumennavigation'
    connection: 'Verbindungsproblem'
    errorTitle: 'Diese Seite konnte nicht geladen werden.'
    retry: 'Erneut versuchen'
    notMirrored: 'Noch nicht übernommen'
    missingTitle: 'Diese Seite ist noch nicht Teil des Redesigns.'
    missingLede: 'Möglicherweise ist sie auf der aktuellen USI-Website verfügbar.'
    openOriginal: 'Auf usi.ch öffnen'
    searchInstead: 'Stattdessen suchen'
    onThisPage: 'Auf dieser Seite'
    inSection: 'In diesem Bereich'
    directory: 'Auf der Originalseite ist dies vor allem ein Verzeichnis – siehe die Links nebenan.'
    quickLinks: 'Schnellzugriff'
    synced: (date) -> "Von usi.ch übernommen · #{date}"
    translatedNotice: 'Die USI veröffentlicht diese Seite auf Englisch und Italienisch. Diese deutsche Fassung ist eine Übersetzung – massgebend ist das Original.'
    translatedFrom: 'Englisches Original lesen'
    notTranslated: 'Diese Seite ist noch nicht übersetzt. Hier lesen Sie vorerst das englische Original.'
    playVideo: 'Video abspielen'
    media: 'Medien'
    previous: 'Zurück'
    next: 'Weiter'
    slideOf: (i, n) -> "#{i} von #{n}"

  search:
    dialog: 'USI durchsuchen'
    placeholder: 'Studiengänge, Seiten, Dienstleistungen suchen…'
    results: 'Ergebnisse'
    noResults: (q) -> "Keine Ergebnisse für «#{q}»."
    noResultsHint: 'Versuchen Sie einen Studiengang, eine Dienstleistung («Wohnen», «Stipendien») oder einen Campus.'
    groups: { goto: 'Direkt zu', programmes: 'Studiengänge', pages: 'Seiten' }
    navigate: 'navigieren'
    open: 'öffnen'
    close: 'schliessen'
    loading: 'Index wird geladen…'
    indexed: (n) -> "#{n} Seiten indexiert"
    shortcuts:
      study: { title: 'Studiengang finden', subtitle: 'Alle Bachelor- und Masterstudiengänge der USI' }
      explore: { title: 'Alle Seiten entdecken', subtitle: 'Die ganze Universität nach Themen' }
      colophon: { title: 'Kolophon', subtitle: 'Wie diese Ausgabe gebaut ist' }

  notFound:
    title: 'Seite nicht gefunden'
    heading: 'Dieser Weg führt in den See.'
    lede: 'Die gesuchte Seite gibt es hier nicht. Suchen Sie danach – oder kehren Sie zurück an Land.'
    search: 'Suchen'
    home: 'Zur Startseite'

  footer:
    label: 'Fusszeile'
    address: 'Via Buffi 13, 6900 Lugano, Schweiz'
    exploreAll: (n) -> "Alle #{n} Seiten entdecken"
    sourced: 'Inhalte von'
    concept: 'Ein unabhängiges Redesign-Konzept, gebaut mit einem ausgemusterten Stack.'
    colophon: 'Kolophon'
    motto: 'Frei gestalten, verantwortungsvoll handeln.'

  colophon:
    title: 'Kolophon'
    eyebrow: 'Kolophon'
    headingA: 'Gebaut mit dem Stack,'
    headingB: 'den wir alle hinter uns gelassen haben.'
    lede: 'Diese Ausgabe der USI-Website ist von Grund auf mit neun Technologien geschrieben, zu denen erfahrene Frontend-Entwicklerinnen und -Entwickler seit Jahren nicht mehr greifen. Dieselben echten Inhalte, dasselbe Designsystem – nur ein anderes Jahrzehnt unter der Haube.'
    role: 'Aufgabe'
    better: 'Was wir besser gemacht haben'
    era: (year) -> "Erschienen #{year}"
    principles: 'Grundsätze'
    principleList: [
      'Klare Struktur: Jede Ansicht ist eine Backbone.View mit explizitem Rendern und Abbauen – keine verwaisten Listener zwischen den Seiten.'
      'Ein Bundle, eine Anfrage: RequireJS-Module, mit r.js zu einer einzigen minifizierten Datei gebündelt und anschliessend mit AES-256-GCM versiegelt.'
      'Barrierefrei von Anfang an: Sprunglink, Ansage beim Seitenwechsel, Fokusführung, Tastatursuche und Farbkontraste nach WCAG AA.'
      'Echte Inhalte: Tausende Seiten von usi.ch auf Englisch, Italienisch und Schweizer Hochdeutsch, pro Sprache bei Bedarf geladen.'
    ]
    stack:
      coffeescript:
        role: 'Der gesamte Anwendungscode, die Build-Tasks und die Tests.'
        better: 'Kleine Module, keine Klassenhierarchien und kompilierter Code, den unser eigener Test-Runner prüft.'
      backbone:
        role: 'Router, Models, Collections und Views.'
        better: 'Views verwalten ihr eigenes DOM und räumen beim Seitenwechsel auf; die Filter des Studiengangsfinders liegen in einem Model, das mit der URL synchronisiert ist.'
      jquery:
        role: 'DOM-Events, delegierte Handler, Ajax und die Zahlenanimationen.'
        better: 'Version 3.7 mit allen Sicherheitskorrekturen, durchgehend delegierte Events und keine Plugins.'
      underscore:
        role: 'Hilfsfunktionen für Listen, Debouncing und Gruppierung.'
        better: 'Nur reine Funktionen – deshalb läuft die Suchmaschine auch in Node und ist dort getestet.'
      handlebars:
        role: 'Sämtliche Templates, beim Build vorkompiliert.'
        better: 'Ausgeliefert wird nur die kleine Runtime, nicht der Compiler; Inhalte werden standardmässig maskiert, Helper übernehmen Sprache und Links.'
      requirejs:
        role: 'AMD-Module und der Optimierer r.js.'
        better: 'Explizite Abhängigkeiten pro Modul, gebündelt in eine Datei samt Loader.'
      less:
        role: 'Das Designsystem: Tokens, Mixins und die Fakultätsfarben.'
        better: 'Kompiliert zu CSS-Custom-Properties, so wechseln helles und dunkles Design zur Laufzeit.'
      grunt:
        role: 'Der Build: Kompilieren, Vorkompilieren, Bündeln, Testen, Ausliefern und Versiegeln.'
        better: 'Eigene, für dieses Projekt geschriebene Tasks statt einer Wand aus Plugins.'
      moment:
        role: 'Lokalisierte Daten auf Englisch, Italienisch und Deutsch.'
        better: 'Gebündelt sind nur die zwei zusätzlichen Sprachen, die wir brauchen.'
