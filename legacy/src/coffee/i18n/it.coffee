# Italiano: la terminologia dell'USI (Formazione, Facoltà, Porte aperte…).
define ->
  meta:
    siteName: 'USI — Università della Svizzera italiana'
    edition: 'Legacy Edition'
    description: 'Il sito dell’USI, ricostruito con uno stack front-end del 2012.'

  nav:
    main: 'Principale'
    programmes: 'Corsi di studio'
    explore: 'Esplora'
    search: 'Cerca'
    searchShort: 'Cerca'
    menu: 'Menu'
    close: 'Chiudi'
    skip: 'Vai al contenuto'
    language: 'Lingua'
    home: 'USI Legacy Edition, pagina iniziale'
    lock: 'Blocca'
    lockLabel: 'Blocca questa anteprima'

  theme:
    light: 'Tema chiaro'
    dark: 'Tema scuro'
    system: 'Tema di sistema'
    change: (current) -> "Cambia tema (attuale: #{current})"

  sections:
    education: { label: 'Formazione', blurb: 'Bachelor, Master, dottorato e formazione continua.' }
    research: { label: 'Ricerca', blurb: 'Istituti, progetti e supporto alla ricerca.' }
    innovation: { label: 'Innovazione', blurb: 'Start-up, trasferimento tecnologico e partenariati.' }
    university: { label: 'Università', blurb: 'Chi siamo, campus, servizi e informazioni pratiche.' }
    other: { label: 'Altro', blurb: '' }

  levels: { bachelor: 'Bachelor', master: 'Master', phd: 'Dottorato', executive: 'Executive' }

  faculties:
    architecture: { name: 'Accademia di architettura', short: 'Architettura' }
    'biomedical-sciences': { name: 'Facoltà di scienze biomediche', short: 'Scienze biomediche' }
    communication: { name: 'Facoltà di comunicazione, cultura e società', short: 'Comunicazione, cultura e società' }
    economics: { name: 'Facoltà di scienze economiche', short: 'Scienze economiche' }
    informatics: { name: 'Facoltà di scienze informatiche', short: 'Scienze informatiche' }
    theology: { name: 'Facoltà di Teologia di Lugano (affiliata)', short: 'Teologia' }

  home:
    eyebrow: 'Università della Svizzera italiana · Lugano'
    mottoA: 'Creare liberamente,'
    mottoB: 'agire responsabilmente.'
    lede: 'Una delle dodici università pubbliche ufficialmente riconosciute in Svizzera: sei Facoltà, quattro campus e una comunità da 115 Paesi, all’incrocio tra cultura italiana e ricerca internazionale.'
    intentStudy: 'Cerco'
    anyLevel: 'un corso di studio'
    levelOption: (level) -> "un #{level}"
    intentIn: 'in'
    anyField: 'qualsiasi ambito'
    intentLevelLabel: 'Livello'
    intentFieldLabel: 'Ambito'
    showProgrammes: 'Mostra i corsi'
    searchHint: (n) -> "Oppure cerca tra #{n} pagine: premi / ovunque"
    factsLabel: 'L’USI in cifre'
    facts:
      students: 'studenti'
      staff: 'docenti e ricercatori'
      countries: 'Paesi rappresentati'
      founded: 'anno di fondazione'
    factsSource: 'Fonte: ritratto dell’USI'
    study:
      eyebrow: 'Formazione'
      title: 'Corsi tenuti da chi fa ricerca.'
      lede: (n) -> "#{n} corsi di Bachelor e Master, molti dei quali in inglese."
      all: 'Tutti i corsi'
      scrollLeft: 'Scorri a sinistra'
      scrollRight: 'Scorri a destra'
      rail: 'Corsi in evidenza'
    faculties:
      eyebrow: 'Facoltà'
      title: 'Sei facoltà. Un campus molto connesso.'
      lede: 'Abbastanza piccola per conoscere i tuoi professori, abbastanza ampia per attraversare le discipline.'
      count: (n) -> if n is 1 then '1 corso' else "#{n} corsi"
    events:
      eyebrow: 'All’USI'
      title: 'Conferenze, seminari ed eventi.'
      lede: 'Dal calendario eventi dell’USI.'
    areas:
      eyebrow: 'Orientati'
      title: 'Tutto ciò che l’USI pubblica, in ordine.'
      lede: (pages, kWords) -> "#{pages} pagine reali, #{kWords}mila parole, riorganizzate in una struttura finalmente navigabile."
      allIn: (section) -> "Tutte le pagine di #{section}"
    cta:
      eyebrow: 'Il prossimo passo'
      title: 'Vieni a scoprire Lugano di persona.'
      find: 'Trova un corso'
      search: 'Cerca le porte aperte'
    scene:
      label: 'Il Campus Ovest dell’USI a Lugano, con studenti nel cortile e il Monte San Salvatore sullo sfondo'
      caption: 'Campus Ovest, Lugano'
      credit: 'Foto: USI'
    legacy:
      eyebrow: 'Dietro le quinte'
      title: 'Nove tecnologie in pensione, un sito moderno.'
      lede: 'Nessun framework di questo decennio: CoffeeScript, Backbone, jQuery e compagni, usati come gli sviluppatori senior avrebbero sempre voluto.'
      cta: 'Leggi il colophon'

  study:
    title: 'Trova un corso di studio'
    eyebrow: 'Trova il tuo corso'
    headingA: 'Trova il corso'
    headingB: 'giusto per te.'
    lede: 'Tutti i Bachelor e Master pubblicati su usi.ch, in un unico posto. Filtra per livello, facoltà o lingua d’insegnamento: la tua selezione resta nell’indirizzo, così puoi condividerla.'
    filters: 'Filtri'
    search: 'Cerca'
    searchPlaceholder: 'es. finanza, IA'
    level: 'Livello'
    all: 'Tutti'
    faculty: 'Facoltà'
    allFaculties: 'Tutte le facoltà'
    taughtIn: 'Lingua d’insegnamento'
    any: 'Qualsiasi'
    english: 'Inglese'
    italian: 'Italiano'
    count: (n) -> if n is 1 then '1 corso' else "#{n} corsi"
    emptyTitle: 'Nessun corso corrisponde ai filtri.'
    emptyHint: 'Prova a rimuoverne uno, oppure cerca in tutto il sito.'
    reset: 'Azzera i filtri'

  programme:
    kind: (level) -> "Corso di #{level}"
    credits: 'ECTS'
    semesters: (n) -> if n is 1 then '1 semestre' else "#{n} semestri"
    english: 'Inglese'
    italian: 'Italiano'
    and: 'e'
    translated: 'Tradotto'
    englishOnly: 'Solo in inglese'
    apply: 'Candidati'

  explore:
    title: 'Esplora'
    eyebrow: 'Esplora'
    headingA: (n) -> "#{n} pagine reali,"
    headingB: 'un’unica interfaccia, chiara.'
    lede: (kWords) -> "Tutte le pagine pubbliche riprese da usi.ch, circa #{kWords}mila parole, organizzate e ricercabili. Scegli un tema o inizia a scrivere."
    filter: 'Filtra le pagine'
    placeholder: 'Filtra le pagine: alloggio, borse di studio, regolamenti…'
    everything: 'Tutto'
    sections: 'Sezioni'
    count: (n) -> "#{n} pagine"
    more: 'Mostra altre'
    left: (n) -> "(ne restano #{n})"
    failed: 'Impossibile caricare l’indice delle pagine. Ricarica la pagina.'
    empty: 'Nessuna pagina corrisponde. Prova con un termine più generico.'

  page:
    loading: 'Caricamento della pagina'
    breadcrumb: 'Percorso'
    connection: 'Problema di connessione'
    errorTitle: 'Non siamo riusciti a caricare questa pagina.'
    retry: 'Riprova'
    notMirrored: 'Non ancora ripresa'
    missingTitle: 'Questa pagina non fa ancora parte del nuovo sito.'
    missingLede: 'Potrebbe essere ancora disponibile sul sito attuale dell’USI.'
    openOriginal: 'Apri su usi.ch'
    searchInstead: 'Cerca'
    onThisPage: 'In questa pagina'
    inSection: 'In questa sezione'
    directory: 'Sul sito originale questa pagina è soprattutto un indice: trovi i collegamenti a lato.'
    quickLinks: 'Link rapidi'
    synced: (date) -> "Sincronizzato da usi.ch · #{date}"
    translatedNotice: ''
    translatedFrom: ''
    notTranslated: ''
    playVideo: 'Guarda il video'
    media: 'Contenuti multimediali'
    previous: 'Precedente'
    next: 'Successivo'
    slideOf: (i, n) -> "#{i} di #{n}"

  search:
    dialog: 'Cerca nell’USI'
    placeholder: 'Cerca corsi, pagine, servizi…'
    results: 'Risultati'
    noResults: (q) -> "Nessun risultato per «#{q}»."
    noResultsHint: 'Prova con il nome di un corso, un servizio («alloggio», «borse di studio») o un campus.'
    groups: { goto: 'Vai a', programmes: 'Corsi di studio', pages: 'Pagine' }
    navigate: 'naviga'
    open: 'apri'
    close: 'chiudi'
    loading: 'Caricamento dell’indice…'
    indexed: (n) -> "#{n} pagine indicizzate"
    shortcuts:
      study: { title: 'Trova un corso di studio', subtitle: 'Tutti i Bachelor e Master dell’USI' }
      explore: { title: 'Esplora tutte le pagine', subtitle: 'Sfoglia l’università per tema' }
      colophon: { title: 'Colophon', subtitle: 'Come è stata costruita questa edizione' }

  notFound:
    title: 'Pagina non trovata'
    heading: 'Questa strada finisce nel lago.'
    lede: 'La pagina che cerchi non esiste. Prova a cercarla, oppure torna sulla terraferma.'
    search: 'Cerca'
    home: 'Torna alla home'

  footer:
    label: 'Piè di pagina'
    address: 'Via Buffi 13, 6900 Lugano, Svizzera'
    exploreAll: (n) -> "Esplora tutte le #{n} pagine"
    sourced: 'Contenuti tratti da'
    concept: 'Un progetto di redesign indipendente, costruito con uno stack in pensione.'
    colophon: 'Colophon'
    motto: 'Creare liberamente, agire responsabilmente.'

  colophon:
    title: 'Colophon'
    eyebrow: 'Colophon'
    headingA: 'Costruito con lo stack'
    headingB: 'che tutti abbiamo abbandonato.'
    lede: 'Questa edizione del sito dell’USI è stata scritta da zero con nove tecnologie che gli sviluppatori front-end senior hanno smesso di usare da anni. Stessi contenuti reali, stesso design system: un altro decennio sotto il cofano.'
    role: 'Ruolo'
    better: 'Cosa abbiamo fatto meglio'
    era: (year) -> "Uscito nel #{year}"
    principles: 'Principi'
    principleList: [
      'Struttura progressiva: ogni vista è una Backbone.View con render e smontaggio espliciti, senza listener dimenticati tra una pagina e l’altra.'
      'Un solo bundle, una sola richiesta: moduli RequireJS compilati con r.js in un unico file minificato, poi sigillato con AES-256-GCM.'
      'Accessibile per impostazione: link per saltare al contenuto, annuncio delle pagine, gestione del focus, ricerca da tastiera e contrasti WCAG AA.'
      'Contenuti reali: migliaia di pagine di usi.ch in inglese, italiano e tedesco svizzero, caricate su richiesta per lingua.'
    ]
    stack:
      coffeescript:
        role: 'Tutto il codice dell’applicazione, i task di build e i test.'
        better: 'Moduli piccoli, nessuna gerarchia di classi e codice compilato verificato dal nostro test runner.'
      backbone:
        role: 'Router, modelli, collezioni e viste.'
        better: 'Le viste gestiscono il proprio DOM e si smontano a ogni cambio di pagina; i filtri del finder vivono in un modello sincronizzato con l’URL.'
      jquery:
        role: 'Eventi DOM, gestori delegati, Ajax e le animazioni dei numeri.'
        better: 'Versione 3.7 con le correzioni di sicurezza, delega degli eventi ovunque e nessun plugin.'
      underscore:
        role: 'Funzioni per collezioni, debounce e raggruppamenti.'
        better: 'Solo funzioni pure, così il motore di ricerca gira ed è testato anche in Node.'
      handlebars:
        role: 'Tutti i template, precompilati in fase di build.'
        better: 'Viene distribuito solo il piccolo runtime, non il compilatore; i contenuti sono protetti per impostazione e gli helper gestiscono lingue e link.'
      requirejs:
        role: 'Moduli AMD e l’ottimizzatore r.js.'
        better: 'Dipendenze esplicite per ogni modulo, riunite in un solo file con il loader incluso.'
      less:
        role: 'Il design system: token, mixin e la palette delle facoltà.'
        better: 'Compila in proprietà CSS personalizzate, così il tema chiaro e scuro cambiano al volo.'
      grunt:
        role: 'La build: compilazione, precompilazione, bundle, test, server e sigillo.'
        better: 'Task scritti su misura per il progetto invece di un muro di plugin.'
      moment:
        role: 'Date localizzate in inglese, italiano e tedesco.'
        better: 'Nel bundle solo le due lingue in più che servono.'
