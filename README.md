# Diament

Komponent [USI][1] wspomagający zapisy na tematy prac dyplomowych przez studentów wydziału. 

##### Użytkownicy systemu:
* studenci - mogą logować się na swoje konto i mają dostęp do panelu użytkownika, zapisują się na prace dyplomowe;
* osoby w katedrach odpowiedzialne za prace dyplomowe - wprowadzają do systemu prace dyplomowe oraz mają uprawnienia do ich edycji i usuwania; uprawnienia administracyjne per katedra;
* obsługa dziekanatu - ma wgląd do prac dyplomowych, generuje raporty; uprawnienia administracyjne per wydział;
* promotorzy (pracownicy naukowi wydziału + osoby z zewnątrz) - zarządzają tematami prac dyplomowych, które zgłosili.



##### Opis procesu obiegu prac w systemie:

1. Dla danego rocznika akademickiego, promotorzy wprowadzają swoje tematy prac dyplomowych. Mogą złosić dowolną liczbę prac, jednakże prac zaakceptowanych (z przypisanymi studentami) nie może być więcej niż limit prac ustalony w danej katedrze.
2. Tematy prac są akceptowane, bądź odrzucane przez osoby w katedrach odpowiedzialne za prace dyplomowe.
3. Tematy zaakceptowane zostają natychmiast upublicznione do wglądu dla wszystkich &ndash; nawet dla osób niezalogowanych do systemu.
4. W dniu ustalonym przez osobę z uprawnieniami administratora, otwierane są zapisy na tematy prac &ndash; studenci mogą zapisywać się do tematów. O każdym zapisie do tematu promotor informowany jest drogą e-mailową.
5. Promotorzy akceptują, bądź odrzucają zapisy studentów. Jeżeli promotor nie podejmie żadnej akcji dla danego zapisu, jest on automatycznie odrzucany po 5 dniach od dnia zapisania się przez studenta.
6. Temat pracy po zaakceptowaniu przez promotora nie jest już dostępny do zapisów dla innych studentów.
7. W dniu określonym przez osobę z uprawnieniami administratora, zamykane są zapisy na tematy prac &ndash; studenci nie mogą już zapisywać się do tematów.



##### Zapisy studentów na tematy prac:
* student może zapisać się na dowolną liczbę tematów; 
* do danego tematu może zapisać się dowolna liczba studentów;
* każde zgłoszenie ma taki sam priorytet, nie ma znaczenia również czas zapisu &ndash; oczywiście z punktu widzenia studenta ma znaczenie, bo im szybciej się zapisze, tym ma większe szanse, że promotor wybierze jego do realizacji danej pracy;
* o przypisaniu studenta do danego tematu decyduje promotor pracy &ndash; może odrzucać lub akceptować zgłoszenia studentów;
* jeżeli promotor zaakceptuje dane zgłoszenie, wówczas pozostałe zgłoszenia do danego tematu zostają automatycznie odrzucone &ndash; w obydwu przypadkach student otrzymuje notyfikację e-mail o działaniu promotora;



##### Eksport danych:

Dostępne raporty:

* lista niezapisanych studentów &ndash; format XLS;
* lista tematów promotorów wydziału &ndash; format XLS;
* lista tematów wydziału wraz z przypisanymi studentami &ndash; format XLS;
* statystyki promotorów wydziału &ndash; zestawienie liczby tematów zgłoszonych, wybranych oraz niewybranych dla każdego promotora wydziału w danym roczniku akademickim &ndash; format XLS;
* lista prac dyplomowych w zależności od filtrów (status pracy, katedra, kierunek, promotor, rodzaj pracy) &ndash; format XLS/PDF;

# Demo

Wersja demonstracyjna systemu dostępna jest [tutaj][2].

Przykładowi użytkownicy:

* osoba z uprawnieniami wydziałowego administratora:
Login: `szef@at.edu`

* osoba z uprawnieniami kierownika katedry:
Login: `kierownik@at.edu`

* osoba z uprawnieniami promotora:
Login: `torpeda@at.edu`

* osoba z uprawnieniami studenta:
Login: `babel@at.edu `

Hasło do wszystkich kont: `123qweasdzxc`.



# Wymagania:

* GNU/Linux - praktycznie dowolna dystrybucja, zalecana GNU/Debian
* Ruby >= 2.0
* Ruby on Rails = 4.0.4
* PostgreSQL >= 9.0
* Redis >= 2.8.4
* Memcached >= 1.4.14


# Instalacja

Patrz [USI][1].

Jeżeli potrzebujesz wsparcia przy wdrożeniu systemu, zapraszamy do kontaktu z nami.

# Licencja

AGPL

Patrz plik LICENCE

# Kontakt

biuro@opensoftware.pl

[1]: https://github.com/Opensoftware/USI-Core
