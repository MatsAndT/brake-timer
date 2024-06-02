#let kode(fil) = {
let kode = read(fil)
    block(
    raw(kode, lang: "c"),
    fill: luma(240),
    inset: 8pt,
    radius: 4pt,
    )
}
#set text(
  font: "Calibri",
  size: 11pt
)
#align(center, image("Logo avdelingsmerke.jpg", width: 50%))

#align(center, text(45pt)[
    *Pausevarsler*
])
#align(center, text(17pt)[
    Prosjektoppgave i ING1507
])
\
#grid(
  columns: (1fr, 1fr),
  align(center)[
    Kandidatnr. 772709
  ],
  align(center)[
    Kandidatnr. 772738
  ]
)


#set heading(numbering: "1.")

#set page(
    paper: "a4",
    
    header: [
        Kandidatnr. 772709, Kandidatnr. 772738
        #h(1fr)
        ING1507 Prosjektoppgave
        #h(1fr)
        31.05.2024
    ],
    numbering: "1"
)

#counter(page).update(1)

= Introduksjon
== Prosjektbeskrivelse
Ved å bruke ATmega32-mikrokontrollere og en rekke komponenter, skulle vi ut ifra de ulike konseptene vi har lært gjennom kurset _ING1507 Datamaskinarkitektur_ lage en modul/system som passer i et smarthjem.\
\
#outline(
    title: "Innhold",
    indent: auto,
)
\
= Prosjektidé
== Utfordring
På skolen har vi pause fra undervisningen med omtrent 45 minutters intervaller, dette er det en fastsatt plan på når pausene skal komme. Det er kadett kommandør (KK) som har dette ansvaret, jobben er å følge med på klokken og varsle foredragsholder 5 minutter før en pause starter. Utfordringen for KK er at hen glemmer å følge med på klokken da dette vil ta over for fokuset på det instruktøren sier. Dette resulterer i at pausene ikke kommer når de skal, som da igjen gjør at kadettene sliter med å fokusere når de ikke får avbrekk.

== Løsning
Løsningen vi har kommet opp med er å lage et produkt som varsler KK samt foredragsholderen når disse pausene skal komme, og hvor lenge det er til.

=== Virkemåte
Det er et system bestående av en KK-modul og en lærer-modul. Disse kommuniserer med hverandre over blåtann.

==== KK-modul
Dette er masteren. Den har en Real Time Clock, som er programmert med en alarm som sender et signal ved skolestart. Mikrokontrolleren har ekstern interrupt på dette signalet og vekkes ved dette signalet. Da går den over i å lese av klokken med et intervall på 1 sekund ved hjelp av Compare Match på Timer1 på ATmega32. Når timen starter sender den lengden på timen over blåtann til lærer-modulen. Når pausen starter, sender den lengden på pausen til lærer-modulen. Når skoledagen er over, sender den stop-kommando til lærer-modulen. All konfiurering av skolestart, pauser og skoleslutt konfigureres altså på KK-modulen.
KK-modulen har også en LCD-skjerm som viser gjenværende minutter og sekunder av pausen når det er pause, og gjenværende tid av timen når det er time.

==== Lærer-modul
Dette er slaven. Denne har RX-interrupt fra blåtannmodulen. Da viser den på 7-segment-skjermen gjenværende tid til time/pause, basert på lengden på pausen/timen den får tilsendt hvor den trekker fra tid ved bruk av den interne klokken i mikrokontrolleren. Når det er 5 minutter til pause hever en servo et flagg halvveis opp, når det er pause heves flagget helt. Dette for å tydeliggjøre at det er pause. Når pausen er over, senkes flagget.\
\

= Metode
 En og en komponent ble testet og det ble laget kode for rett funksjonalitet for denne komponenten. Deretter ble disse kodeutsnittene satt sammen i en sammensatt kode for funksjonaliteten på KK-modulen og en sammensatt kode for lærer-modulen.  
Mye inspirasjon, og informasjon om hvordan flere av komponentene som ble brukt i prosjektet fungerer, ble hentet fra leksjonene i ING1507 @Leksjoner_datamaskinarkitektur, samt databladene til de ulike komponentene.
Til slutt ble alt satt i sammen, og kobling ble gjort for de ulike komponentene for å kunne opprette funksjonaliteten beskrevet innledningsvis. KK-modulen ble koblet opp som vist i @koblingsskjema_kk, lærer-moduelen ble koblet opp som vist i @koblingsskjema_laerer.


#figure(
    image("KK-modul.png", width: 70%),
    caption: [
        Koblingssjema for KK-modul
    ],
    supplement: [Figur]
) <koblingsskjema_kk>

#figure(
    image("Laerer-modul.jpeg", width: 70%),
    caption: [
        Koblingssjema for Lærer-modul
    ],
    supplement: [Figur]
) <koblingsskjema_laerer>

== Utstyr
=== KK-modul
- 1x ATmega32 mikrokontroller
- 1x HM-10 blåtannmodul
- 1x DS3231 Real Time Clock
- 1x 16x2 LCD
- 1x Potentiometer
- 2x koblingsbrett
- Flere ledninger og motstander

=== Lærer-modul
- 1x ATmega32 mikrokontroller
- 1x HM-10 blåtannmodul
- 1x 7-segment-skjerm
- 1x Servo
- 2x koblingsbrett
- Flere ledninger og motstander\
\

= Teori
== Servo, PWM
Pulsbreddemodulasjon (PBM/PWM) er en måte å generere et analogt signal fra en mikrokontroller. Ved å modulere bredden på en digital puls får man ulike spenningsnivåer. Når du skal styre de fleste typer servomotorer bruker du PBM til å sende den ønskede posisjonen til servoen. En typisk servomotor forventer en puls hvert 20ms og bredden på pulsen innenfor denne perioden bestemmer vinkelen til servoen. For eksempel kan en 1ms puls være 0 grader, 1.5ms være 90 grader og 2ms være 180 grader. Med å variere pulsbredden innenfor den faste perioden, kan servomotorens posisjon settes nøyaktig.

== USART
USART er en forkortelse for Universal Synchronous Asynchronous Receiver Transmitter. Dette er en protokoll for seriell kommunikasjon som brukes for å sende og motta data mellom mikrokontrollere og andre enheter. Baud rate er antall symboler som sendes eller mottas per sekund.
Blåtannmodulen kommuniserer med en baud rate på 9600. Dette skaper et nøyaktighetsproblem på ATmega32 uten videre konfigurering.
Normal konfigurasjon av USART på ATmega32 med standard klokkehastighet på 1MHz og baud rate på 9600, gir en baud-prescaler med -7% avvik fra en baud-verdi på 9600 (ref. @ATmega32_baudrate). Dette kommer av utregningen på baud-prescaler som gir et så lavt tall at nøyaktigheten blir for dårlig til å nøyaktig kunne nå baud raten på 9600 med en heltalls baud-prescaler. For å overkomme dette dobles USART-klokkehastigheten ved å sette U2X-bit i UCSRA. Da må også utregningen av prescaler dobles. Dette gir et avvik på bare 0.2% på baud raten, noe som er pålitelig nok til å få lest av og sendt data korrekt i svært stor grad.
#figure(
    image("ATmega32 baudrate.png", width: 80%),
    caption: [
        Avvik i baudrate på ATmega32 _(ref. Datablad for ATmega32 @ATmega32_datasheet)_
    ],
    supplement: [Figur]
) <ATmega32_baudrate>
\

== HM-10 Blåtannmodul
En HM-10 blåtannmodul sender seriell data over bluetooth (blåtann). Den har en intern krets som tar seg av alt av prosessering ved overføring over bluetooth og fungerer med standardinnstillinger så snart den blir koblet opp til en spenning på 3-6v. Den kan konfigrureres ved hjelp av AT-kommandoer for å endre innstillinger som baud rate, enhetsnavn, eller om den skal være master eller slave. Det er verdt å merke seg at den interne kretsen kun er 3.3v tolerant. Logikken i ATmega32 er 5v. Dette går fint for signalet fra TX på blåtannmodul til ATmega32, da ATmega32 kan regirstrere et signal på 3.3v. Problematikken er på signalet fra TX på ATmega32 til blåtannmodulen. Den indre kretsen i blåtannmodulen kan skades dersom dette signalet er 5v. Dette løses ved å bruke en spenningsdeler med ulike motstander (se koblingsskjema i @koblingsskjema_kk) på dette signalet fra TX på mikrokontrolleren.

== DS3231 Real Time Clock
DS3231 er en ekstremt nøyaktig klokke som fungerer over I2C. Denne har et minnebatteri, som gjør at klokken fortsetter å gå rett selv om ekstern strøm til enheten kobles fra, dette gjør at den vil kunne vise rett tid i svært lang tid. Enheten har en krystall og en temperatur-kompensert krystall. RTC-en holder styr på sekunder, minutter, timer, ukedag, dato, måned og år. Enheten har også to programmerbare alarmer. 
\
For å hente ut tiden fra RTC senders først adressen til RTC hvor least significant bit (LSB) er satt til 0 over I2C fra masteren (ATmega32 er masteren i dette scenarioet). Dette gjør at RTC-en begynner, og er klar til å respondere på kommende meldinger. Deretter sender masteren den adressen i @DS3231_registers som vi ønsker å lese fra (for eksempel adresse = 03h for å lese av dagen). Deretter sendes repeated start, etterfulgt av adressen til RTC-en hvor LSB er satt til 1. Dette gjør at RTC-en sender byten med data fra denne adressen. Dersom master så sender ACK sendes byten fra neste adresse osv. For å avslutte sendes NACK og Stop. Denne prosessen følger vi i @DS3231_read, og er implementert i @DS3231_read_code.
#figure(
    image("DS3231 registers.png", width: 80%),
    caption: [
        Tidsregistere i DS3231 _(ref. Datablad for DS3231 @DS3231_datasheet)_
    ],
    supplement: [Figur]
) <DS3231_registers>

#figure(
    image("DS3231 read.png", width: 80%),
    caption: [
        Prosess for avlesning DS3231
    ],
    supplement: [Figur]
) <DS3231_read>
\
#figure(
    block(
    ```c
    void RTC_Read_Clock(char read_clock_address) {
        I2C_Start(RTC_Write_address); // Start I2C communication with RTC
        I2C_Write(read_clock_address); // Write address to read
        I2C_Repeated_Start(RTC_Read_address);
        
        second = BDC2value(I2C_Read_Ack());
        minute = BDC2value(I2C_Read_Ack());
        hour = BDC2value(I2C_Read_Nack() & 0b00111111); //Last communication so nack. The two MSB are not relevant
        I2C_Stop();
    }
    ```, 
    fill: luma(240),
    inset: 8pt,
    radius: 4pt,
    ),
    caption: [
            Kode for avlesning DS3231
        ],
    supplement: [Oppføring]
)<DS3231_read_code>

== 7-segment-skjerm
En 7-segment-skjerm er satt sammen av 7 led-lys med felles anode eller katode, hver av led-lysene har en egen pin. Hvis det er flere segmenter satt sammen vil det være en felles anode/katode for hvert segment og alle led-lysene for samme posisjon/samme bokstav er koblet sammen (ref. @7-segment-display). For å vise en bokstav på skjermen må de riktige pinnene settes høye eller lave. 
#figure(
    image("7-segment-display.png", width: 70%),
    caption: [
        7-segment-skjerm _(Bildekilde: @Segment_display)_
    ],
    supplement: [Figur]
) <7-segment-display>

\
= Kodeprinsipper
== KK-modul
=== Alarm på DS3231
_Figurutklipp hentet fra databladet til DS3231 @DS3231_datasheet _\
For prosjektet skal ATmega32 vekkes ved alarmen på DS3231 til kl.08.00. Alarmen settes ved å skrive til alarm-registrene (ref. @DS3231_registers). For å få alarmen til å trigge på sekunder, minutter og timer, settes A1M4 i DS3231-register til 1 (ref. @DS3231_alarm_time). For å oppnå at SQW-pinnen på DS3231 settes til GND når alarmen trigges, slås Interrupt Control på ved å sette INTCN til 1. For at den skal trigge på alarm 1, slås også A1IE på (ref. @DS3231_alarm). Alarm-initieringen er implementert i @DS3231_init_alarm_code. Setting av alarm er implementert i @DS3231_set_alarm. Når flagget for alarmen blir satt, vekkes ATmega32 og går over i å lese av klokken. Flagget må nullstilles manuelt, og gjøres ved å sette bit-en for A1F i @DS3231_alarm_flag til 0. Dette er implementert i @DS3231_clear_alarm_flag.
#figure(
    image("DS3231 alarm time.png", width: 80%),
    caption: [
        Konfigurering av alarm på DS3231
    ],
    supplement: [Figur]
) <DS3231_alarm_time>

#figure(
    image("DS3231 alarm.png", width: 80%),
    caption: [
        Register for å konfigurere blant annet alarm på DS3231
    ],
    supplement: [Figur]
) <DS3231_alarm>

#figure(
    block(    ```c
    void RTC_Alarm_Init(){
        I2C_Start(RTC_Write_address);
        I2C_Write(0xE);		// Bet at the control register position (See datasheet)
        I2C_Write(0b00000101);	// Enabling interrupt Control and Alarm 1 Interrupt Enable
        I2C_Stop();
}
    ```,
    fill: luma(240),
    inset: 8pt,
    radius: 4pt,
    ),
    caption: [
        Kode for å initiere alarm på DS3231
    ],
    supplement: [Oppføring]
) <DS3231_init_alarm_code>

#figure(
    block(
    ```c
    void RTC_Alarm1_Time(char _hour, char _minute, char _second){ // The alarm triggers at the spesified time every day.
        I2C_Start(RTC_Write_address);
        I2C_Write(7);					// Set alarm1 time in register 7
        I2C_Write(value2BDC(_second));
        I2C_Write(value2BDC(_minute));
        I2C_Write(value2BDC(_hour));
        I2C_Write(0b10000000); // Set A1M4 to trigger at that time set
        I2C_Stop();
    }
    ```,
    fill: luma(240),
    inset: 8pt,
    radius: 4pt,
    ),
    caption: [
        Kode for å sette alarm1
    ],
    supplement: [Oppføring]
) <DS3231_set_alarm>

#figure(
    image("DS3231 alarm flag.png", width: 80%),
    caption: [
        Register for å lese av / nullstille flagg
    ],
    supplement: [Figur]
) <DS3231_alarm_flag>

#figure(
    block(
    ```c
    void RTC_Alarm_Clear(){
        I2C_Start(RTC_Write_address);
        I2C_Write(0xF);
        I2C_Write(0b10001000);	// Write 0 at the BSY, A2F and A1F flag.
        I2C_Stop();
    }
    }
    ```,
    fill: luma(240),
    inset: 8pt,
    radius: 4pt,
    ),
    caption: [
        Kode for å nullstille alarm-flagget
    ],
    supplement: [Oppføring]
) <DS3231_clear_alarm_flag>

== Lærer-modul
=== 7-segment-skjerm
Koden til 7-segment-skjermen funker med å skrive et og et individuelt tall til hvert segment, tallet er hentet fra en global variabel som kan oppdateres fra hele programmet. Denne funksjonen kjøres med timer hvert 20ms (50Hz). Det er satt en liste med hvilke porter som må slås på for at tallet skal vises, som hentes fra en liste med indeks som hører til tallet.
#figure(
    block(
    ```c
    void diplay_one_cycle()
    {
        temp = num % 10;
        PORT_DIGIT_SELECT = SegOne;
        PORT_DIGIT_PINS = seg_code[temp];
        _delay_ms(display_delay);
        
        temp = (num / 10) % 10;
        PORT_DIGIT_SELECT = SegTwo;
        PORT_DIGIT_PINS = seg_code[temp];
        _delay_ms(display_delay);
        
        temp = (num / 100) % 10;
        PORT_DIGIT_SELECT = SegThree;
        PORT_DIGIT_PINS = seg_code[temp];
        _delay_ms(display_delay);

        temp = (num / 1000) % 10;
        PORT_DIGIT_SELECT = SegFour;
        PORT_DIGIT_PINS = seg_code[temp];
        _delay_ms(display_delay);
    }
    }
    ```, 
    fill: luma(240),
    inset: 8pt,
    radius: 4pt,
    ),
    caption: [
            Kode for å vise tall på 7-segment-skjerm
        ],
    supplement: [Oppføring]
)<7-segment-code>

= Diskusjon
== Blåtannmodul
Konfigurering av modulen var utfordrende, da det er vanskelig å vite nøyaktig hvordan modulen opererer, særlig med lite dokumentasjon. Slike blåtannmoduler er også moduler det er finnes utallige kopier av der ulike produsenter har ulike standarder. Dette gjør det spesielt vanskelig å finne hvilken type modul, med hvilken konfigurasjon man har, og deretter finne adekvat dokumentasjon for denne. (Utseende på en HC-06, HC-05 og HM-10-modul er tilnærmet identisk, noe som gjør det vanskelig å identifisere hvilken man har). I vårt tilfelle fant vi med mye leting ut at våres modul var av typen HM-10, de var imidlertid ikke helt etter standard, for ved flere av AT-kommandoene som var å finne i ufullstendig dokumentasjon på internett returnerte våres blåtannmoduler med “Error”. Tross dette var vi i stand til å endre rolle mellom slave og master. I vårt prosjekt ble blåtannmodulen brukt ved KK-modulen satt til å være master, og lærer-modulen slave. Etter det vi kunne finne av dokumentasjon på internett om automatisk oppkobling i slave-master-par, fungerte ingen av kommandoene for å sette opp at master-modulen automatisk skulle koble seg opp til slave-modulen ved oppstart. Vi måtte derfor konkludere med at med mangel på rett dokumentasjon for våre blåtannmoduler, var ikke automatisk sammenkobling ved oppstart mulig. Dette resulterte i at man ved oppstart må koble master modulen til seriell tilbobling til PC, for å via AT-kommandoer søke etter nære blåtannmoduler og velge rett, for så å koble opp til denne.

== Virkemåte KK-modul
Det er hensiktsmessig at masteren har mest mulig nøyaktig tid, da lærer-modulen settes etter denne. Derfor ble det brukt intern timer med Compare Match for å lese av klokken med 1 sekunds intervall. Dette gjør at KK-modulen har mest mulig nøyaktig tid, ettersom DS3231-klokken heller ikke har mer nøyaktighet enn 1-sekunds intervall, og mer enn dette er jo heller strengt tatt ikke nødvendig for våres formål. Noen ytteligere optimaliseringer ble også implementert for å kunne spare energi: Alarmen på DS3231 settes til kl.08:00. Slik at når tidspunktet er 08:00 settes SQW-pinnen på DS3231 til GND. KK-modulen har dette signalet som et interrupt-signal, slik at den ikke gjør noe fram til starten av dagen. Så sjekker den ukedagen den er på; dersom det er lørdag eller søndag, går den tilbake til å ikke gjøre noe. Dersom det derimot er hverdag, leser den av klokken over I2C ved hvert tidsintervall. I2C-kommunikasjonen gjør den med bruk av while-løkke mens den sender og venter på ACK, grunnen til dette er at vi er nødt til å ha kontroll på hvor vi er i kommunikasjonsprosessen, da vi først sender adressen vi leser fra, for så å lese av et bestemt antall verdier, der vi får neste verdi ved å sende ACK og må ha kontroll på når vi skal sende NACK og STOP når all klokkedata er mottatt. Ved pause-/timestart senders lengden på pausen eller timen over USART.

== Virkemåte Lærer-modul
Lærer-modulen funker i slavemodus av KK-modulen. Lærer-modulen mottar i starten av et tidsintervall, med type intervall: «b» for pause (brake) og «l» for undervisning (lecture). Om det er en pause som blir sendt vil den sette flagget til å peke opp, og ned hvis det er undervisning. Etter type intervall så kommer hvor lenge intervallet skal vare i minutter. Denne tiden kommer som _string_ og blir gjort om til _int_ og ganget med 60, fordi modulen arbeider i sekunder. Stringen med denne informasjonen blir sendt fra masteren som minutter for å unngå å sende unødvendig mye data. Når det er 5 minutter igjen av en undervisning vil flagget bli heist til midten (45 grader), dette skjer uten at KK-modulen sender noe.
Lærer-modulen bruker alle innebygde timere i mikrokontrolleren, 16 bit timer1 til servoen, 8 bit timer0 for å oppdatere 7-segment-skjermen og 8 bit timer2 for å telle ned hvert sekund, for å få denne timer-en til å telle ned hvert sekund måtte vi bruke et buffer da maks tiden var 262.144ms, den ble satt til ¼ sekund og teller ned et buffer 4 ganger før den teller ned antall sekunder igjen.


= Feilkilder
USART på ATmega32 ble konfigurert til å bruke dobbel hastighet. Dette gjorde at baud-prescaler fikk en verdi som ga den 0.2% avvik ved baud-rate på 9600. Selv om avviket er lite, er det ikke neglisjerbart. Dette kombinert med eventuelle feil under overføring med blåtann, gjør at det er en viss mulighet for at data som sendes fra KK-modulen blir mottatt feil på lærer-modulen, og at denne derfor vil vise feil gjenværende tid.
\
Fordi lærer-modulen bruker intern klokke og et buffer for å telle ned, kan telleren komme ut av takt etter flere minutter. Dette ble vurdert til å ikke være noe problem, da tiden blir maksimalt noen sekunder feil, eneste konsekvens er at det kan komme rare tallkombinasjoner på skjermen og at flagget går til halv mast noen sekunder før/etter dersom klokken skulle gått ut av synk.
\

= Konklusjon
Prosjektet har vært lærerikt, og vi har fått en god forståelse for hvordan de ulike komponentene vi har brukt fungerer. Vi har også fått en god forståelse for hvordan grunnprinsippene i USART, PWM, I2C og interrupt fungerer og hvordan dette kan brukes i praksis. Vi har også fått en god forståelse for hvordan man lager mer sammensatte systemer, og hvilke utfordringer som kommer med dette, noe som har gitt en dypere forståelse for grunnprinsippene ved at problemene har måttet løses i praksis. Bruk av nye komponenter som DS3231 har også gitt mer innsikt i hvordan datablad kan brukes til å forstå hvordan en komponent fungerer, og hvordan kode må skrives for å kunne bruke denne komponenten. 

#show link: underline
= Video
Video av litt hvordan både KK-modulen og lærer-modulen fungerer kan sees på [denne linken](#link("https://mega.nz/file/LBYFmBDZ#xudL_8mmVFRbZSnoe9NqkLAyeW6GrJ2vPHbj7x8PAc8")).

#bibliography(
    "referanser.yml",
    title: "Referanser",
)


#pagebreak()
#set page(numbering: "i")
#counter(page).update(1)




= Vedlegg
== KK_modul
=== KK_module.c
#kode("Main_project/main.c")
=== I2C.h
#kode("Main_project/I2C.h")
=== RTC.h
#kode("Main_project/RTC.h")
=== screen.h
#kode("Main_project/screen.h")

== Lærer_modul
=== Lærer_module.c
#kode("Slave/main.c")
=== segment_display.h
#kode("Slave/segment_display.h")
=== servo.h
#kode("Slave/servo.h")

== Felles
=== USART.h
#kode("Main_project/USART.h")