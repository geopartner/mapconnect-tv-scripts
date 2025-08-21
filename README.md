# mapconnect-tv-scripts
Det sql der skal afvikles for etablere forbindelse til CloudConnect fra MapConnect

Følgende informationer skal samles
    
1. Projekt id fra CloudConnect. ( også kaldet token)
2. Api key skal skabes i CloudConnect.
3. View i CloudConnect skal skabes.
4. Database navn i MapConnect skal bestemmes.

Filen create_tv_tables.sql skal kopiers og de fire informationer listet ovenfor skal erstattes  de søge strenge, der er angivet i toppen af filen.
create_tv_tables.sql består af 13 seperate step.
Hvert step skal afvikles fra pgAdmin og man skal være sikker på det enkelte step er fuldført før man går videre til den næste.
