#let kode(fil) = {
let kode = read(fil)
block(
    raw(kode, lang: "c"),
    fill: luma(240),
    inset: 8pt,
    radius: 4pt,
)
}

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
    Kandidatnr. xx
  ],
  align(center)[
    Kandidatnr. yy
  ]
)


#set heading(numbering: "1.")
#set text(
  font: "Calibri",
  size: 11pt
)
#set page(
    paper: "a4",
    
    header: [
        Kandidatnr. xx, Kandidatnr. yy
        #h(1fr)
        ING1507 Prosjektoppgave
        #h(1fr)
        27.05.2024
    ],
    numbering: "1 / 1"
    
)
#counter(page).update(1)

\
\
= Introduksjon
== Prosjektbeskrivelse
Ved bruk av ATmega32 mikrokontrollere og en rekke komponenter, skulle vi ut ifra de ulike aspektene vi har lært gjennom kurset _Datamaskinarkitektur_ lage en modul/system som passer i et smarthjem.\
\
#outline(
    title: "Innhold",
    indent: auto,
)
\
= Prosjektidé
== Utfordring
På skolen har vi pause fra undervisningen med omtrent 45 minutter intervaller, dette er det en fast satt plan på når pausene skal komme. Det er kadett kommandør (KK) som har dette ansvaret, jobben er å følge med på klokken og varsle foredragsholder med 5 minutter før en pause starter. Utfordringen for KK er at hen glemmer å følge med på klokken da dette vil ta over for fokuset på det instruktøren sier. Som resulterer i at pausene ikke kommer når de skal, som da igjen gjør at kadettene sliter med å fokusere når de ikke får avbrekk.

== Løsning
Løsningen vi har kommet opp med er å lage et produkt som varsler KK samt foredragsholderen når disse pausene skal komme, og hvor lenge det er til.

=== Virkemåte
Det er et system bestående av en kk-modul og en lærer-modul. Disse kommuniserer med hverandre over blåtann.

=== KK-modul
Dette er masteren. Den har en Real Time Clock, som er programmert med en alarm som sender et signal ved skolestart. Mikrokontrolleren har ekstern interrupt på dette signalet og vekkes ved dette signalet. Da går den over i å lese av klokken konstant. Når timen starter sender den lengden på timen over blåtann til lærer-modulen. Når pausen starter, sender den lengden på pausen til lærer-modulen. Når skoledagen er over, sender den stop-kommando til lærer-modulen. All konfiurering av skolestart, pauser og skoleslutt konfigureres altså på KK-modulen.
KK-modulen har også en LCD som viser gjenværende minutter og sekunder av pausen når det er pause, og gjenværende tid av timen når det er time.

=== Lærer-modul
Dette er slaven. Denne har RX-interrupt fra blåtannmodulen. Den sover fram til den får melding over blåtann. Da viser den på 7-segment-skjermen gjenværende tid til time/pause, basert på lengden på pausen/timen den får tilsendt hvor den trekker fra tid ved bruk av den interne klokken i mikrokontrolleren. Når det er pause hever en servo et flagg for å tydeliggjøre at det er pause. Når pausen er over, senkes flagget.\
\

= Metode
Kobling ble gjort for de ulike komponentene for å kunne opprette funksjonaliteten beskrevet innledningsvis. Deretter ble en og en komponent testet og det ble laget kode for rett funksjonalitet for denne komponenten. Deretter ble disse kodeutsnittene satt sammen i en sammensatt kode for funksjonaliteten på kk-modulen og en sammensatt kode for lærer-modulen. 

== Utstyr
=== KK-modul
- 1x ATmega32 mikrokontroller
- 1x HM-10 blåtannmodul
- 1x DS3231 Real Time Clock
- 1x 16x2 LCD
- 2x koblingsbrett
- Flere ledninger og motstander

=== Lærer-modul
- 1x ATmega32 mikrokontroller
- 1x HM-10 blåtannmodul
- 1x 7-segment-skjerm
- 1x Servo
- 3x koblingsbrett
- Flere ledninger og motstander\
\

= Teori
== USART
Blåtannmodulen kommuniserer med en baud-rate på 9600. Dette skaper et nøyaktighetsproblem på ATmega32 uten videre konfigurering.
Normal konfigurasjon av USART på ATmega32 med standard klokkehastighet på 1MHz og baud rate på 9600, gir en baud-prescaler med -7% avvik fra en baud-verdi på 9600 (ref. @ATmega32_baudrate). Dette kommer av utregningen på baud-prescaler som gir et så lavt tall at nøyaktigheten blir for dårlig til å nøyaktig kunne nå baudraten på 9600 med en heltalls baud-prescaler. For å overkomme dette dobles USART-klokkehastigheten ved å sette U2X-bit i UCSRA. Da må også utregningen av prescaler dobles. Dette gir et avvik på bare 0.2% på baud-raten, noe som er pålitelig nok til å få lest av data korrekt i svært stor grad.
#figure(
    image("ATmega32 baudrate.png", width: 70%),
    caption: [
        Avvik i baudrate på ATmega32 (ref. ATmega32 datablad @ATmega32_datasheet)
    ]
) <ATmega32_baudrate>

== HM-10 Blåtannmodul
En HM-10 blåtannmodul sender UART data over bluetooth. Den har en intern krets som tar seg alt prosessering ved overføring over bluetooth og fungerer med standardinnstillinger så snart den blir koblet opp til en spenning på 3-6v. Den kan konfigrureres ved hjelp av AT-kommandoer for å endre innstillinger som baud-rate, enhetsnavn, eller om den skal være master eller slave. Det er verdt å merke seg at den interne kretsen kun er 3.3v tolerant. Logikken i ATmega32 er 5v. Dette går fint for signalet fra TX på blåtannmodul til ATmega32, da ATmega32 kan regirstrere et signal på 3.3v. Problematikken er på signalet fra TX på ATmega32 til blåtannmodulen. Den indre kretsen i blåtannmodulen kan skades dersom dette signalet er 5v. Dette løses ved å bruke en spenningsdeler med ulike motstander (se koblingsskjema) på dette signalet fra TX på mikrokontrolleren.

== DS3231 Real Time Clock
DS3231 er en ekstremt nøyaktig klokke som fungerer over I2C. Denne har et minnebatteri, som gjør at klokken fortsetter å gå rett selv om ekstern strøm til enheten kobles fra, dette gjør at den vil kunne vise rett tid i svært lang tid. Enheten har en krystall og en temperatur-kompensert krystall. RTC-en holder styr på sekunder, minutter, timer, ukedag, dato, måned og år. Enheten har også to programmerbare alarmer. For å hente ut tiden fra RTC senders først adressen til RTC hvor least significant bit (LSB) er satt til 0 over I2C fra masteren (ATmega32 er masteren i dette scenarioet). Dette gjør at RTC-en begynner, og er klar til å respondere på kommende meldinger. Deretter sender adressen vi ønsker å lese fra (“word address”) dette er adressen i @DS3231_registers (for eksempel adresse = 03h for å lese av dagen). Deretter sendes repeated start, etterfulgt av adressen til RTC-en hvor LSB er satt til 1. Dette gjør at RTC-en sender byten med data fra denne adressen. Dersom master så sender ACK sendes byten fra neste adresse osv. For å avslutte sendes NACK og Stop. Denne prosessen følger vi i @DS3231_read, og er implementert i @DS3231_read_code.
#figure(
    image("DS3231 registers.png", width: 70%),
    caption: [
        Tidsregistere i DS3231 (ref. DS3231 datablad @DS3231_datasheet)
    ]
) <DS3231_registers>

#figure(
    image("DS3231 read.png", width: 70%),
    caption: [
        Prosess for avlesning DS3231
    ]
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
        ]
)<DS3231_read_code>

== 7-segment-skjerm
En 7-segment-skjerm er satt sammen av 7 led-lys med felles anode eller katode, hver av led-lysene har en egen pin. Hvis det er flere segmenter satt sammen vil det være en felles anode/katode for hvert segment og alle led-lysene for samme posisjon/samme bokstav er koblet sammen (ref. @7-segment-display). For å vise en bokstav på skjermen må de riktige pinnene settes høye eller lave. 
#figure(
    image("7-segment-display.png", width: 70%),
    caption: [
        7-segment-skjerm
    ]
) <7-segment-display>
\
= Kodeprinsipper
== KK-modul
=== Alarm på DS3231
_Utklipp hentet fra databladet til DS3231 @DS3231_datasheet _\
For prosjektet skal ATmega32 vekkes ved alarmen på DS3231 til kl.08.00. Alarmen settes ved å skrive til alarm-registrene (ref. @DS3231_registers). For å få alarmen til å trigge på sekunder, minutter og timer, settes A1M4 i DS3231-register til 1 (ref. @DS3231_alarm_time) For å oppnå at når alarmen trigges settes SQW-pinnen til GND, slås Interrupt Control på ved å sette INTCN til 1. For at den skal trigge på alarm 1, slås også A1IE på. (ref. @DS3231_alarm). Alarm-initieringen er implementert i @DS3231_init_alarm_code. Setting av alarm er implementert i @DS3231_set_alarm. Når flagget for alarmen blir satt, vekkes ATmega32 og går over i å lese av klokken konstant. Flagget må nullstilles manuelt, og gjøres ved å sette bit-en for A1F i @DS3231_alarm_flag til 0. Dette er implementert i @DS3231_clear_alarm_flag.
#figure(
    image("DS3231 alarm time.png", width: 70%),
    caption: [
        Konfigurering av alarm på DS3231
    ]
) <DS3231_alarm_time>

#figure(
    image("DS3231 alarm.png", width: 70%),
    caption: [
        Register for å konfigurere blant annet alarm på DS3231
    ]
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
    ]
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
    ]
) <DS3231_set_alarm>

#figure(
    image("DS3231 alarm flag.png", width: 70%),
    caption: [
        Register for å lese av / nullstille flagg
    ]
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
    ]
) <DS3231_clear_alarm_flag>


= Diskusjon
== Blåtannmodul
Konfigurering av modulen var utfordrende, da det er vanskelig å vite nøyaktig hvordan modulen opererer, særlig med lite dokumentasjon. Slike blåtannmoduler er også moduler det er finnes utallige kopier av der ulike produsenter har ulike standarder. Dette gjør det spesielt vanskelig å finne hvilken type modul med hvilken konfigurasjon man har, og deretter å finne adekvat dokumentasjon for denne. (Utseende på en HC-06, HC-05 og HM-10-modul er tilnærmet identisk, noe som gjør det vanskelig å identifisere hvilken man har). I vårt tilfelle fant vi med mye leting ut at våres modul var av typen HM-10, de var imidlertid ikke helt etter standard, for flere av AT-kommandoene som var å finne i ufullstendig dokumentasjon på internett returnerte våres blåtann moduler med “Error”. Tross dette var vi i stand til å endre rolle mellom slave og master. I vårt prosjekt ble blåtannmodulen brukt ved KK-modulen satt til å være master, og lærer-modulen slave. Etter det vi kunne finne av dokumentasjon på internett om automatisk oppkobling i slave-master-par fungerte ingen av kommandoene for å sette opp at master-modulen automatisk skulle koble seg opp til slave-modulen ved oppstart. Vi måtte derfor konkludere med at med mangel på rett dokumentasjon for våre blåtannmoduler var ikke automatisk sammenkobling ved oppstart mulig. Dette resulterte i at man ved oppstart må koble master modulen til seriell tilbobling til PC, for å via AT-kommandoer søke etter nære blåtann-moduler og velge rett, for så å koble opp til denne.
== Virkemåte KK-modul
Det er hensiktsmessig at masteren har mest mulig nøyaktig tid, da Lærer-modulen settes etter denne. Det kunne blitt brukt interne timere i KK-modulen, og lest av klokken DS3231 med relativt lange intervallpauser, noe som kunne spart energi. Det ble alikevel besluttet at ettersom KK-modulen ikke kjøres fra et batteri, ville det være mer hensiktsmessig å heller lese av klokken kontinuelig, for å få mest mulig korrekt tid. Noen optimaliseringer ble imidlertid implementert: 1. Alarmen på DS3231 settes til kl.08.00. Slik at når tidspunktet er 08.00 settes SQW-pinnen på DS3231 til GND. KK-modulen har dette signalet som et interrupt-signal, slik at den er i sleep fram til starten av dagen. Deretter leser den kontinuelig av klokken over I2C. Dette gjør den med bruk av while mens den sender og venter på ACK, grunnen til dette er at vi er nødt til å ha kontroll på hvor vi er i kommunikasjonsprosessen, da vi først sender adressen vi leser fra, for så å lese av et bestemt antall verdier, der vi får neste verdi ved å sende ACK og må ha kontroll på når vi skal sende NACK og STOP når all klokkedata er mottatt. Ved pause-/timestart senders lengden på pausen eller timen over USART. Denne USART-kommunikasjonen gjøres gjennom interrupts for å ikke blokkere hovedprogrammet. Dette gjør at KK-modulen kan fortsette å lese av klokken mens den sender data over USART. Dette gjør at KK-modulen har mest mulig korrekt tid, og kan sende data til Lærer-modulen på riktig tidspunkt.

= Feilkilder
USART på ATmega32 ble konfigurert til å bruke dobbel hastighet. Dette gjorde at baud-prescaler fikk en verdi som ga den 0.2% avvik ved baud-rate på 9600. Selv om avviket er lite, er det ikke neglisjerbart. Dette kombinert med eventuelle feil under overføring med blåtann, gjør at det er en viss mulighet for at data som sendes fra KK-modulen blir mottatt feil på Lærer-modulen, og at denne derfor vil vise feil gjenværende tid.

#bibliography(
    "referanser.yml",
    title: "Referanser",
)